//
//  ChatViewController.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 27/01/23.
//

import UIKit
import MessageKit
import VideoSDKRTC
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    /// Meeting Reference
    public var meeting: Meeting
    
    /// Chat Topic
    public var topic: String
    
    /// Message List
    private var messages: [Message] = []
    
    // Time Formatter
    private let timeFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    
    // MARK: - Init
    
    init(meeting: Meeting, topic: String) {
        self.meeting = meeting
        self.topic = topic
        
        let pubsubMessages = meeting.pubsub.getMessagesForTopic(topic)
        messages = pubsubMessages.map({ Message(pubsubMessage: $0) })
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        configureMessageCollectionView()
        configureMessageInputBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadAndScrollToLast()
    }
    
    // MARK: - Public
    
    func showNewMessage(_ pubsubMessage: PubSubMessage) {
        let message = Message(pubsubMessage: pubsubMessage)
        messages.append(message)
        
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
}

// MARK: - Helpers

extension ChatViewController {
    
    // relod and scroll to last message
    func reloadAndScrollToLast() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
    
    // checks if last section is visible
    func isLastSectionVisible() -> Bool {
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        ChatUser(senderId: meeting.localParticipant.id, displayName: meeting.localParticipant.displayName)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
}

// MARK: - MessagesDisplayDelegate, MessagesLayoutDelegate

extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.senderId == meeting.localParticipant.id ? "You" : message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 15)])
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 25
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: timeFormatter.string(from: message.sentDate),
            attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 15)])
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 25
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        UIColor.white
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        UIColor.systemDarkBackground?.withAlphaComponent(0.4) ?? UIColor(named: "systemDarkBackground")!
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return MessageStyle.bubble
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // send (publish) message
        meeting.pubsub.publish(topic: topic, message: text, options: ["persist": true])
        
        // reset textView
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
    }
}


// MARK: - Setup

extension ChatViewController {
    
    func setupNavigationBar() {
        edgesForExtendedLayout = []
        self.navigationItem.title = topic
        self.setNavigationBarAppearance(self.navigationController!.navigationBar)
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.backgroundColor = UIColor(named: "chatBackgroundColor")!
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        // no avatars
        let layout = messagesCollectionView.messagesCollectionViewFlowLayout
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        
        let incomingInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        let outgoingInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: incomingInsets))
        layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: incomingInsets))
        layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: outgoingInsets))
        layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: outgoingInsets))
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.backgroundView.backgroundColor = UIColor(named: "chatItemBackgroundColor")
        messageInputBar.inputTextView.backgroundColor = UIColor(named: "chatItemBackgroundColor")
        
        // textview
        messageInputBar.inputTextView.tintColor = UIColor.white
        messageInputBar.inputTextView.textColor = UIColor.white
        messageInputBar.inputTextView.isImagePasteEnabled = false
        
        // send button
        messageInputBar.sendButton.setTitleColor(UIColor.white, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .highlighted)
        messageInputBar.sendButton.activityViewColor = UIColor.lightGray
    }
}

