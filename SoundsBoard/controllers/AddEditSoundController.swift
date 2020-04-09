//
//  AddSoundController.swift
//  SoundsBoard
//
//  Created by Mohammed Ghannm on 08.03.20.
//  Copyright © 2020 Mohammed Ghannm. All rights reserved.
//

import UIKit
import SwiftySound
import CoreData
import MobileCoreServices
import NVActivityIndicatorView
import MultiSlider
import Intents
import IntentsUI

class AddEditSoundController: UIViewController, NVActivityIndicatorViewable, UINavigationControllerDelegate{
    
    public enum ControllerState{
        case Add
        case Edit
        case AddExternal
    }
    
    public var editableSound:SoundObject?
    public var externalAudioURL:URL?
    
    var currentSoundFileName: String?
    var currentSoundImage: UIImage?
    var moc : NSManagedObjectContext!
    var state:ControllerState = .Add
    var soundSaved = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        self.moc = appDelegate.persistentContainer.viewContext
        
        self.title = "Create new Sound"
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = doneButton
        
        setUpUI()
    }
    
    func setUpUI(){
        setUpAddImageButtonView()
        setUpNameInputView()
        if state == .Edit{
            
            guard let soundFileName = editableSound!.fileName else {
                return
            }
            fillSoundNameAndImage(editableSound!)
            setUpPlayerView(nameTextInput)
            newSoundReady(soundFileName)
        }
        
        if state == .Add{
            setUpInputTypesView()
            setUpPlayerView(inputTypesView)
        }
        
        if state == .AddExternal{
            setUpPlayerView(nameTextInput)
            handleURL(externalAudioURL!)
        }
    }
    
    func setUpAddImageButtonView(){
        self.view.addSubview(addImageButton)
        let imageIcon = UIImage(named: "round_add_photo_alternate_black_48pt")
        addImageButton.setImage(imageIcon, for: .normal)
        addImageButton.contentMode = .center
        addImageButton.snp.makeConstraints{ (make) -> Void in
            make.width.height.equalTo(100)
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
        }
        addImageButton.clipsToBounds = true
        addImageButton.layer.borderWidth    = 0.5
        addImageButton.layer.cornerRadius   = (addImageButton.frame.size.width) / 2
        addImageButton.layer.borderColor    = UIColor.lightGray.cgColor
        addImageButton.addTarget(self, action: #selector(addImageButtonClicked(_:)), for: .touchUpInside)
    }
    
    func setUpNameInputView(){
        self.view.addSubview(nameTextInput)
        nameTextInput.placeholder = "Sound name"
        nameTextInput.font = UIFont.systemFont(ofSize: 15)
        nameTextInput.borderStyle = UITextField.BorderStyle.roundedRect
        nameTextInput.delegate = self
        nameTextInput.clearButtonMode = UITextField.ViewMode.whileEditing
        nameTextInput.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        nameTextInput.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.addImageButton.snp.bottom).offset(16)
            make.width.equalTo(self.view.snp.width).inset(UIEdgeInsets(top: 0,left: 16,bottom: 0,right: 16))
            make.centerX.equalTo(self.view.snp.centerX)
        }
    }
    
    func setUpInputTypesView(){
        guard editableSound == nil else {
            return
        }
        self.view.addSubview(inputTypesView)
        inputTypesView.axis             = NSLayoutConstraint.Axis.horizontal
        inputTypesView.distribution     = UIStackView.Distribution.fillEqually
        inputTypesView.alignment        = UIStackView.Alignment.center
        inputTypesView.spacing          = 16
        
        openRecorderButton.setTitle("Record Audio", for: .normal)
        openFileButton.setTitle("Pick Audio File", for: .normal)
        
        openRecorderButton.clipsToBounds = true
        openRecorderButton.layer.borderWidth = 0.5
        openRecorderButton.layer.cornerRadius    = (openRecorderButton.frame.size.width) / 2
        openRecorderButton.layer.borderColor = UIColor.lightGray.cgColor
        
        
        openRecorderButton.clipsToBounds = true
        openFileButton.layer.borderWidth = 0.5
        openFileButton.layer.borderColor = UIColor.lightGray.cgColor
        openFileButton.layer.cornerRadius    = (openFileButton.frame.size.width) / 2
        
        
        inputTypesView.addArrangedSubview(openRecorderButton)
        inputTypesView.addArrangedSubview(openFileButton)
        
        inputTypesView.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.nameTextInput.snp.bottom).offset(32)
            make.width.equalTo(self.view.snp.width).inset(UIEdgeInsets(top: 0,left: 16,bottom: 0,right: 16))
            make.centerX.equalTo(self.view.snp.centerX)
        }
        
        openRecorderButton.addTarget(self, action: #selector(onOpenRecorderButton), for: .touchUpInside)
        openFileButton.addTarget(self, action: #selector(onOpenFileButton), for: .touchUpInside)
    }
    
    
    func setUpPlayerView(_ upperView: UIView){
        trimSlider = MultiSlider()
        self.view.addSubview(trimSlider)
        trimSlider.inputView?.isUserInteractionEnabled = false
        trimSlider.orientation = .horizontal
        trimSlider.outerTrackColor = .red
        trimSlider.minimumValue = 0
        trimSlider.maximumValue = 100
        trimSlider.snapStepSize = 1
        trimSlider.isHapticSnap = true
        trimSlider.valueLabelPosition = .notAnAttribute
        trimSlider.tintColor = .systemBlue
        trimSlider.trackWidth = 8
        trimSlider.hasRoundTrackEnds = true
        trimSlider.thumbCount = 2
        
        self.view.addSubview(startTimeLabel)
        startTimeLabel.text = "00:00"
        startTimeLabel.font =  UIFont.monospacedDigitSystemFont(ofSize: 16, weight: UIFont.Weight.light)
        startTimeLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.view.snp.left).offset(16)
            make.centerY.equalTo(self.trimSlider.snp.centerY)
        }
        
        self.view.addSubview(endTimeLabel)
        endTimeLabel.text = "00:00"
        endTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: UIFont.Weight.light)
        endTimeLabel.snp.makeConstraints{ (make) -> Void in
            make.right.equalTo(self.view.snp.right).offset(-16)
            make.centerY.equalTo(self.trimSlider.snp.centerY)
        }
        
        trimSlider.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(upperView.snp.bottom).offset(82)
            make.left.equalTo(startTimeLabel.snp.right).offset(8)
            make.right.equalTo(endTimeLabel.snp.left).offset(-8)
            make.centerX.equalTo(self.view.snp.centerX)
        }
        trimSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged) // continuous changes
        trimSlider.addTarget(self, action: #selector(sliderDragEnded(_:)), for: . touchUpInside) // sent when drag ends
        
        self.view.addSubview(hintLabel)
        hintLabel.text = "Move the slider thumbs to trim the sound."
        hintLabel.textColor = .lightGray
        hintLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: UIFont.Weight.light)
        hintLabel.textAlignment = .center
        hintLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.trimSlider.snp.bottom).offset(16)
            make.width.equalTo(self.view.snp.width)
        }
        
        self.view.addSubview(playBackDurationView)
        playBackDurationView.text = "Current duration: 04:58"
        playBackDurationView.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: UIFont.Weight.light)
        playBackDurationView.textColor = .lightGray
        playBackDurationView.textAlignment = .center
        playBackDurationView.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(hintLabel.snp.bottom).offset(16)
            make.width.equalTo(self.view.snp.width)
        }
        
        self.view.addSubview(playerControllersView)
        
        playerControllersView.axis             = NSLayoutConstraint.Axis.horizontal
        playerControllersView.distribution     = UIStackView.Distribution.equalCentering
        playerControllersView.alignment        = UIStackView.Alignment.center
        
        playerControllersView.addArrangedSubview(stopButton)
        playerControllersView.addArrangedSubview(playButton)
        playerControllersView.addArrangedSubview(pauseButton)
        
        playerControllersView.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(upperView.snp.bottom).offset(32)
            make.width.equalTo(self.view.frame.width / 2)
            make.centerX.equalTo(self.view.snp.centerX)
        }
        
        if let playIcon = UIImage(named:"round_play_arrow_black_48pt"){
            playButton.setImage(playIcon, for: .normal)
            playButton.snp.makeConstraints{ (make) -> Void in
                make.width.height.equalTo(50)
            }
        }
        
        if let pauseIcon = UIImage(named: "round_pause_black_48pt"){
            pauseButton.setImage(pauseIcon , for: .normal)
            pauseButton.snp.makeConstraints{ (make) -> Void in
                make.width.height.equalTo(50)
            }
        }
        
        if let stopIcon = UIImage(named: "round_stop_black_48pt"){
            stopButton.setImage(stopIcon , for: .normal)
            stopButton.snp.makeConstraints{ (make) -> Void in
                make.width.height.equalTo(50)
            }
        }
        
        playButton.addTarget(self, action: #selector(onPlayButtonClicked), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(onPauseButtonClicked), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(onStopButtonClicked), for: .touchUpInside)
        
        playerVisiblity(isHidden: true)
    }
    
    func setUpSiriShortcutButton(){
        self.view.addSubview(addSiriShortcut)
        addSiriShortcut.setTitle("Add Siri shortcut", for: .normal)
        
        addSiriShortcut.clipsToBounds = true
        addSiriShortcut.layer.borderWidth = 0.5
        addSiriShortcut.layer.cornerRadius   = (addSiriShortcut.frame.size.width) / 2
        addSiriShortcut.layer.borderColor = UIColor.lightGray.cgColor
        
        addSiriShortcut.snp.makeConstraints{ (make) -> Void in
            make.width.equalTo(self.view.frame.width/2)
            make.top.equalTo(playBackDurationView.snp.bottom).offset(16)
            make.centerX.equalTo(self.view.snp.centerX)
        }
        addSiriShortcut.addTarget(self, action: #selector(presentSiriViewController), for: .touchUpInside)
    }
    
    // MARK: - Player Controllers
    
    func playerVisiblity(isHidden:Bool){
        playerControllersView.isHidden = isHidden
        startTimeLabel.isHidden = isHidden
        endTimeLabel.isHidden = isHidden
        trimSlider.isHidden = isHidden
        hintLabel.isHidden = isHidden
        playBackDurationView.isHidden = isHidden
    }
    
    @objc func onPlayButtonClicked(_ sender: UIButton){
        if let soundFileName = currentSoundFileName{
            let startTime = TimeInterval(exactly: trimSlider.value[0])
            let endTime = TimeInterval(exactly: trimSlider.value[1])
            AudioPlayer.sharedInstance.play(soundFileName: soundFileName, startTime: startTime, endTime: endTime, checkPlayed: true)
        }
    }
    
    @objc func onPauseButtonClicked(_ sender: UIButton){
        AudioPlayer.sharedInstance.pause()
    }
    
    @objc func onStopButtonClicked(_ sender: UIButton){
        AudioPlayer.sharedInstance.stop()
    }
    
    @objc func sliderChanged(_ slider: MultiSlider){
        updateStartEndTrimmingViews(start: Float(slider.value[0]), end: Float(slider.value[1]))
    }
    
    @objc func sliderDragEnded(_ slider: MultiSlider){
        
    }
    
    func updateStartEndTrimmingViews(start:Float, end:Float){
        AudioPlayer.sharedInstance.stop()
        self.startTimeLabel.text = AudioPlayer.sharedInstance.getFormatedTime(timeInSeconds: start)
        self.endTimeLabel.text = AudioPlayer.sharedInstance.getFormatedTime(timeInSeconds: end)
        let newDuraiton = end - start
        self.newDurationString = AudioPlayer.sharedInstance.getFormatedTime(timeInSeconds: newDuraiton)
        self.playBackDurationView.text = "Current duration: \(newDurationString)"
    }
    
    var newDurationString = ""
    
    func setUpTrimmer(_ soundOriginalDuration: Int){
        self.endTimeLabel.text = AudioPlayer.sharedInstance.getFormatedTime(timeInSeconds: soundOriginalDuration)
        self.trimSlider.maximumValue = CGFloat(soundOriginalDuration)
        self.trimSlider.value = [0,CGFloat(soundOriginalDuration)]
        self.newDurationString = AudioPlayer.sharedInstance.getFormatedTime(timeInSeconds: soundOriginalDuration)
        self.playBackDurationView.text = "Current duration: \(newDurationString)"
    }
    
    // MARK: - Audio Recorder
    
    @objc func onOpenRecorderButton(_ sender: UIButton){
        AudioPlayer.sharedInstance.stop()
        let audioRecorderController = AudioRecorderController()
        audioRecorderController.audioRecorderDelegate = self
        self.navigationController!.pushViewController(audioRecorderController, animated: true)
    }
    
    func newSoundReady(_ newSoundFileName: String){
        if let old = self.currentSoundFileName{
            AudioPlayer.sharedInstance.stop()
            SoundsFilesManger.deleteSoundFile(old)
        }
        let soundOriginalDuration = Int(AudioPlayer.sharedInstance.getDuration(soundFileName: newSoundFileName))
        if(soundOriginalDuration == 0){
            SoundsFilesManger.deleteSoundFile(newSoundFileName)
            AlertsManager.showPlayingAlert(self)
        }else{
            setUpSiriShortcutButton()
            playerVisiblity(isHidden: false)
            self.currentSoundFileName = newSoundFileName
            setUpTrimmer(Int(soundOriginalDuration))
        }
    }
    
    func fillSoundNameAndImage(_ sound:SoundObject){
        nameTextInput.text = sound.name
        if let soundImageData = sound.image{
            currentSoundImage = UIImage(data: soundImageData)
            addImageButton.setImage(UIImage(data: soundImageData), for: .normal)
        }
    }
    
    // MARK: - Audio Picker
    
    @objc func onOpenFileButton(_ sender: UIButton){
        AudioPlayer.sharedInstance.stop()
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.audiovisual-content"], in: .open)
        importMenu.delegate = self
        self.present(importMenu, animated: true, completion: nil)
    }
    
    // MARK: - Saving & Closing
    
    func trimmed() -> Bool{
        guard let soundFileName = self.currentSoundFileName else{
            print("geneeratedName is empty")
            return false
        }
        let soundOriginalDuration:Int = Int(AudioPlayer.sharedInstance.getDuration(soundFileName: soundFileName))
        let newDuraiton = Int(trimSlider.value[1] - trimSlider.value[0])
        return soundOriginalDuration != newDuraiton
    }
    
    @objc func doneButtonClicked(_ sender: Any){
        AudioPlayer.sharedInstance.stop()
        guard let name = nameTextInput.text, name.isNotEmpty else{
            print("Name is empty")
            return
        }
        guard let image = self.currentSoundImage else{
            print("Image is empty")
            return
        }
        
        guard let soundFileName = self.currentSoundFileName else{
            print("geneeratedName is empty")
            return
        }
        if trimmed(){
            startAnimating()
            let startTime = Int(trimSlider.value[0])
            let endTime = Int(trimSlider.value[1])
            SoundsFilesManger.trimSound(soundFileName: soundFileName, startTime: startTime, endTime: endTime, delegate: self)
        }else{
            saveSound(name, image, soundFileName)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard !soundSaved else{
            return
        }
        if isMovingFromParent {
            if let soundGenratedName = currentSoundFileName{
                AudioPlayer.sharedInstance.stop()
                if state == .Add{
                    SoundsFilesManger.deleteSoundFile(soundGenratedName)
                }
            }
        }
    }
    
    // MARK: - Image Pickers
    
    @objc func addImageButtonClicked(_ sender: UIButton){
        let alert = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default , handler:{ (UIAlertAction)in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default , handler:{ (UIAlertAction)in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func openCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func openGallary(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    lazy var doneButton         = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonClicked))
    lazy var addImageButton     = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    lazy var nameTextInput      = UITextField()
    lazy var inputTypesView     = UIStackView()
    
    lazy var playButton         = UIButton()
    lazy var stopButton         = UIButton()
    lazy var pauseButton        = UIButton()
    lazy var openRecorderButton = UIButton(type: .system)
    lazy var openFileButton     = UIButton(type: .system)
    
    lazy var playerControllersView  = UIStackView()
    lazy var trimSlider             = MultiSlider()
    lazy var startTimeLabel         = UILabel()
    lazy var endTimeLabel           = UILabel()
    lazy var playBackDurationView   = UILabel()
    lazy var trimmedDuration        = UILabel()
    lazy var hintLabel              = UILabel()
    
    lazy var addSiriShortcut        = UIButton(type: .system)
}

extension AddEditSoundController: AudioRecorderViewControllerDelegate{
    func audioRecorderFinished(_ newSoundFileName: String) {
        newSoundReady(newSoundFileName)
    }
}

extension AddEditSoundController: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        handleURL(url)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleURL(_ url:URL){
        let fileType = SoundsFilesManger.checkFileType(url)
        if fileType == SupportedFileTypes.unknowen{
            AlertsManager.showFileNotSuportedAlert(self)
            return
        }
        SoundsFilesManger.copyFile(url, self)
    }
}

extension AddEditSoundController: SoundsFilesMangerCopyDelegate{
    func copyDidStart() {
        startAnimating(message: "Copying")
    }
    
    func convertDidStart() {
        stopAnimating()
        startAnimating(message: "Converting")
    }
    
    func copyAndConvertDidFinish(_ soundFileName: String) {
        stopAnimating()
        newSoundReady(soundFileName)
    }
    
    func copyDidFaild(_ erorr: Error, fileName: String) {
        stopAnimating()
        AlertsManager.showImportFailedAlert(self, fileName: fileName)
    }
}


extension AddEditSoundController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        self.currentSoundImage = image
        self.addImageButton.setImage(image, for: .normal)
    }
}

extension AddEditSoundController: SoundsFilesMangerTrimDelegate{
    func trimDidFinshed() {
        stopAnimating()
        saveSound(nameTextInput.text!, currentSoundImage!, currentSoundFileName!)
    }
    
    func trimDidFaild(_ erorr: Error) {
        stopAnimating()
        print(erorr)
    }
}

extension AddEditSoundController: UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}


extension AddEditSoundController{
    
    func saveSound(_ soundName:String, _ soundImage:UIImage, _ soundFileName:String){
        if state == .Add || state == .AddExternal{
             saveNewSound(soundName, soundImage, soundFileName)
        }else{
            saveExsitSound(soundName, soundImage, soundFileName)
        }
    }
    
    func saveExsitSound(_ newSoundName:String, _ newSoundImage:UIImage, _ newSoundFileName:String){
        guard let exsitSound = editableSound else{
            return
        }
        exsitSound.name = newSoundName
        exsitSound.image = newSoundImage.pngData()
        exsitSound.fileName = newSoundFileName
        do {
            try moc.save()
            soundSaved = true
            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print(error)
            moc.rollback()
        }
    }
    
    func saveNewSound(_ soundName:String, _ soundImage:UIImage, _ soundFileName:String){
        if let soundEntity = NSEntityDescription.entity(forEntityName: "SoundObject", in: moc){
            let soundObject = NSManagedObject(entity: soundEntity, insertInto: moc)
            soundObject.setValue(soundName, forKeyPath: "name")
            soundObject.setValue(soundImage.pngData(), forKeyPath: "image")
            soundObject.setValue(soundFileName, forKeyPath: "fileName")
            do {
                try moc.save()
                soundSaved = true
                self.navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                print(error)
                moc.rollback()
            }
        }
    }
}


extension AddEditSoundController {
    @objc func presentSiriViewController() {
        guard let soundName = nameTextInput.text, let soundFileName = currentSoundFileName else {
            return
        }
        guard soundName.isNotEmpty else{
            return
        }
        let activity = NSUserActivity(activityType: "com.example.SoundsBoard.play.sound")
        activity.title = soundName
        activity.keywords = Set([soundFileName])
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.isEligibleForPublicIndexing = true
        activity.suggestedInvocationPhrase = "Play \(String(describing: soundName)) on SoundBoard"
        let viewController = INUIAddVoiceShortcutViewController(shortcut: INShortcut(userActivity: activity))
        viewController.modalPresentationStyle = .formSheet
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
}

extension AddEditSoundController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true)
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true)
    }
}