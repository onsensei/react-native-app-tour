//
//  MaterialShowcase.swift
//  MaterialShowcase
//
//  Created by Quang Nguyen on 5/4/17.
//  Copyright © 2017 Aromajoin. All rights reserved.
//
import UIKit

@objc public protocol MaterialShowcaseDelegate: class {
    @objc optional func showCaseWillDismiss(showcase: MaterialShowcase)
    @objc optional func showCaseDidDismiss(showcase: MaterialShowcase)
}

public class MaterialShowcase: UIView {
    
    @objc public enum BackgroundTypeStyle: Int {
        case circle //default
        case full//full screen
    }
    
    // MARK: Material design guideline constant
    let BACKGROUND_ALPHA: CGFloat = 0.96
    let TARGET_HOLDER_RADIUS: CGFloat = 44
    let TEXT_CENTER_OFFSET: CGFloat = 44 + 20
    let INSTRUCTIONS_CENTER_OFFSET: CGFloat = 20
    let LABEL_MARGIN: CGFloat = 40
    let TARGET_PADDING: CGFloat = 20
    
    // Other default properties
    let LABEL_DEFAULT_HEIGHT: CGFloat = 50
    let BACKGROUND_DEFAULT_COLOR = UIColor.fromHex(hexString: "#2196F3")
    let TARGET_HOLDER_COLOR = UIColor.white
    let TARGET_TRAN_DEFAULT = false
    
    // MARK: Animation properties
    var ANI_COMEIN_DURATION: TimeInterval = 0.5 // second
    var ANI_GOOUT_DURATION: TimeInterval = 0.5  // second
    var ANI_TARGET_HOLDER_SCALE: CGFloat = 2.2
    let ANI_RIPPLE_COLOR = UIColor.white
    let ANI_RIPPLE_ALPHA: CGFloat = 0.5
    let ANI_RIPPLE_SCALE: CGFloat = 1.6
    
    var offsetThreshold: CGFloat = 88
    
    // MARK: Private view properties
    var containerView: UIView!
    var targetView: UIView!
    var backgroundView: UIView!
    var targetHolderView: UIView!
    var hiddenTargetHolderView: UIView!
    var targetRippleView: UIView!
    var targetCopyView: UIView!
    var targetButton: UIButton!
    var instructionView: MaterialShowcaseInstructionView!
    
    // MARK: Public Properties
    
    // Background
    @objc public var backgroundPromptColor: UIColor!
    @objc public var backgroundPromptColorAlpha: CGFloat = 0.0
    @objc public var backgroundViewType: BackgroundTypeStyle = .circle
    // Tap zone settings
    // - false: recognize tap from all displayed showcase.
    // - true: recognize tap for targetView area only.
    @objc public var isTapRecognizerForTagretView: Bool = true
    // Target
    @objc public var shouldSetTintColor: Bool = true
    @objc public var targetTintColor: UIColor!
    @objc public var targetHolderRadius: CGFloat = 0.0
    @objc public var targetHolderColor: UIColor!
    @objc public var targetTran: Bool = false
    // Button
    @objc public var buttonVisable: Bool = true
    @objc public var buttonTextColor: UIColor!
    @objc public var buttonBGColor: UIColor!
    @objc public var buttonText: String!
    @objc public var buttonRadius: CGFloat = 0.0
    @objc public var buttonTextSize: CGFloat = 0.0
    // Text
    @objc public var primaryText: String!
    @objc public var secondaryText: String!
    @objc public var primaryTextColor: UIColor!
    @objc public var secondaryTextColor: UIColor!
    @objc public var primaryTextSize: CGFloat = 0.0
    @objc public var secondaryTextSize: CGFloat = 0.0
    @objc public var primaryTextFont: UIFont?
    @objc public var secondaryTextFont: UIFont?
    @objc public var primaryTextAlignment: NSTextAlignment = .left
    @objc public var secondaryTextAlignment: NSTextAlignment = .left
    // Animation
    @objc public var aniComeInDuration: TimeInterval = 0.0
    @objc public var aniGoOutDuration: TimeInterval = 0.0
    @objc public var aniRippleScale: CGFloat = 0.0
    @objc public var aniRippleColor: UIColor!
    @objc public var aniRippleAlpha: CGFloat = 0.0
    // Delegate
    @objc public weak var delegate: MaterialShowcaseDelegate?
    
    public init() {
        // Create frame
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        super.init(frame: frame)
        
        configure()
    }
    
    // No supported initilization method
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public APIs
extension MaterialShowcase {
    
    /// Sets a general UIView as target
    @objc public func setTargetView(view: UIView) {
        targetView = view
        
        if let label = targetView as? UILabel {
            targetTintColor = label.textColor
            backgroundPromptColor = label.textColor
        } else if let button = targetView as? UIButton {
            let tintColor = button.titleColor(for: .normal)
            targetTintColor = tintColor
            backgroundPromptColor = tintColor
        } else {
            targetTintColor = targetView.tintColor
            backgroundPromptColor = targetView.tintColor
        }
    }
    
    /// Sets a UIBarButtonItem as target
    @objc public func setTargetView(barButtonItem: UIBarButtonItem) {
        if let view = (barButtonItem.value(forKey: "view") as? UIView)?.subviews.first {
            targetView = view
        }
    }
    
    /// Sets a UITabBar Item as target
    @objc public func setTargetView(tabBar: UITabBar, itemIndex: Int) {
        let tabBarItems = orderedTabBarItemViews(of: tabBar)
        if itemIndex < tabBarItems.count {
            targetView = tabBarItems[itemIndex]
            targetTintColor = tabBar.tintColor
            backgroundPromptColor = tabBar.tintColor
        } else {
            print ("The tab bar item index is out of range")
        }
    }
    
    /// Sets a UITableViewCell as target
    @objc public func setTargetView(tableView: UITableView, section: Int, row: Int) {
        let indexPath = IndexPath(row: row, section: section)
        targetView = tableView.cellForRow(at: indexPath)?.contentView
        // for table viewcell, we do not need target holder (circle view)
        // therefore, set its radius = 0
        targetHolderRadius = 0
    }
    
    /// Shows it over current screen after completing setup process
    @objc public func show(animated: Bool = true, completion handler: (()-> Void)?) {
        initViews()
        alpha = 0.0
        containerView.addSubview(self)
        self.layoutIfNeeded()
        
        let scale = TARGET_HOLDER_RADIUS / (backgroundView.frame.width / 2)
        let center = backgroundView.center
        
        backgroundView.transform = CGAffineTransform(scaleX: scale, y: scale) // Initial set to support animation
        self.backgroundView.center = self.targetHolderView.center
        if animated {
            UIView.animate(withDuration: aniComeInDuration, animations: {
                self.targetHolderView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.backgroundView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.backgroundView.center = center
                self.alpha = 1.0
            }, completion: { _ in
                self.startAnimations()
            })
        } else {
            self.alpha = 1.0
        }
        // Handler user's action after showing.
        if let handler = handler {
            handler()
        }
    }
}

// MARK: - Utility API
extension MaterialShowcase {
    /// Returns the current showcases displayed on screen.
    /// It will return null if no showcase exists.
    public static func presentedShowcases() -> [MaterialShowcase]? {
        guard let window = UIApplication.shared.delegate?.window else {
            return nil
        }
        return window?.subviews.filter({ (view) -> Bool in
            return view is MaterialShowcase
        }) as? [MaterialShowcase]
    }
}

// MARK: - Setup views internally
extension MaterialShowcase {
    
    /// Initializes default view properties
    func configure() {
        backgroundColor = UIColor.clear
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        containerView = window
        setDefaultProperties()
    }
    
    func setDefaultProperties() {
        // Background
        backgroundPromptColor = BACKGROUND_DEFAULT_COLOR
        backgroundPromptColorAlpha = BACKGROUND_ALPHA
        // Target view
        targetTintColor = BACKGROUND_DEFAULT_COLOR
        targetHolderColor = TARGET_HOLDER_COLOR
        targetHolderRadius = TARGET_HOLDER_RADIUS
        targetTran = TARGET_TRAN_DEFAULT
        // Text
        primaryText = MaterialShowcaseInstructionView.PRIMARY_DEFAULT_TEXT
        secondaryText = MaterialShowcaseInstructionView.SECONDARY_DEFAULT_TEXT
        buttonText = MaterialShowcaseInstructionView.BUTTON_DEFAULT_TEXT
        primaryTextColor = MaterialShowcaseInstructionView.PRIMARY_TEXT_COLOR
        secondaryTextColor = MaterialShowcaseInstructionView.SECONDARY_TEXT_COLOR
        primaryTextSize = MaterialShowcaseInstructionView.PRIMARY_TEXT_SIZE
        secondaryTextSize = MaterialShowcaseInstructionView.SECONDARY_TEXT_SIZE
        // Animation
        aniComeInDuration = ANI_COMEIN_DURATION
        aniGoOutDuration = ANI_GOOUT_DURATION
        aniRippleAlpha = ANI_RIPPLE_ALPHA
        aniRippleColor = ANI_RIPPLE_COLOR
        aniRippleScale = ANI_RIPPLE_SCALE
        // Button
        buttonVisable = MaterialShowcaseInstructionView.BUTTON_DEFAULT_VISABLE
        buttonText = MaterialShowcaseInstructionView.BUTTON_DEFAULT_TEXT
        buttonBGColor = MaterialShowcaseInstructionView.BUTTON_DEFAULT_BG_COLOR
        buttonTextColor = MaterialShowcaseInstructionView.BUTTON_DEFAULT_TEXT_COLOR
        buttonRadius = MaterialShowcaseInstructionView.BUTTON_DEFAULT_RADIUS
        buttonTextSize = MaterialShowcaseInstructionView.BUTTON_TEXT_SIZE
    }
    
    func startAnimations() {
        let options: UIViewKeyframeAnimationOptions = [.curveEaseInOut, .repeat]
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: options, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                self.targetRippleView.alpha = self.ANI_RIPPLE_ALPHA
                self.targetHolderView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.targetRippleView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.targetHolderView.transform = CGAffineTransform.identity
                self.targetRippleView.alpha = 0
                self.targetRippleView.transform = CGAffineTransform(scaleX: self.aniRippleScale, y: self.aniRippleScale)
            })
            
        }, completion: nil)
    }
    
    func initViews() {
        let center = calculateCenter(at: targetView, to: containerView)
        
        addTargetRipple(at: center)
        addTargetHolder(at: center)
        addTarget(at: center)
        
        //In iPad version InstructionView was add to backgroundView
        if UIDevice.current.userInterfaceIdiom == .pad {
            addBackground()
        }
        
        addInstructionView(at: center)
        instructionView.layoutIfNeeded()
        
        //In iPhone version InstructionView was add to self view
        if UIDevice.current.userInterfaceIdiom != .pad {
            addBackground()
        }
        
        // Disable subview interaction to let users click to general view only
        subviews.forEach({$0.isUserInteractionEnabled = true})
        
        if isTapRecognizerForTagretView {
            //Add gesture recognizer for targetCopyView
            targetCopyView.addGestureRecognizer(tapGestureRecoganizer())
            targetCopyView.isUserInteractionEnabled = true
            if buttonVisable {
                targetButton = instructionView.buttonLabel
                targetButton.addGestureRecognizer(tapGestureRecoganizer())
                targetButton.isUserInteractionEnabled = true
            }
        } else {
            // Add gesture recognizer for both container and its subview
            addGestureRecognizer(tapGestureRecoganizer())
        }
    }
    
    /// Add background which is a big circle
    private func addBackground() {
        
        switch self.backgroundViewType {
        case .circle:
            let radius: CGFloat!
            
            let center = targetCopyView.center//getOuterCircleCenterPoint(for: targetCopyView)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                radius = 300.0
            } else {
                radius = getOuterCircleRadius(center: center, textBounds: instructionView.frame, targetBounds: targetCopyView.frame)
            }
            
            backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: radius * 2,height: radius * 2))
            backgroundView.center = center
            
            backgroundView.asCircle()
        case .full:
            backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height))
        }
        
        let radiuss = getOuterCircleRadius(center: center, textBounds: instructionView.frame, targetBounds: targetCopyView.frame)
        
        let p = targetView.convert(targetView.center, to: self)
        
        backgroundView.backgroundColor = backgroundPromptColor.withAlphaComponent(backgroundPromptColorAlpha)
        
        if targetTran {
            // Create a path with the rectangle in it.
            let p = CGMutablePath()
            p.addArc(center: CGPoint(x: backgroundView.bounds.midX, y: backgroundView.bounds.midY), radius: targetHolderRadius , startAngle: 0.0, endAngle: 2 * (22/7), clockwise: false)
            p.addRect(CGRect(x: 0, y: 0, width: backgroundView.frame.width, height: backgroundView.frame.height))
            
            let ml = CAShapeLayer()
            ml.backgroundColor = UIColor.black.cgColor
            ml.path = p;
            ml.fillRule = kCAFillRuleEvenOdd
            
            // Release the path since it's not covered by ARC.
            backgroundView.layer.mask = ml
            backgroundView.clipsToBounds = true
        }
        
        insertSubview(backgroundView, belowSubview: targetRippleView)
    }
    
    /// A background view which add ripple animation when showing target view
    private func addTargetRipple(at center: CGPoint) {
        targetRippleView = UIView(frame: CGRect(x: 0, y: 0, width: targetHolderRadius * 2,height: targetHolderRadius * 2))
        targetRippleView.center = center
        targetRippleView.backgroundColor = aniRippleColor
        targetRippleView.alpha = 0.0 //set it invisible
        targetRippleView.asCircle()
        addSubview(targetRippleView)
        
    }
    
    /// A circle-shape background view of target view
    private func addTargetHolder(at center: CGPoint) {
        hiddenTargetHolderView = UIView()
        hiddenTargetHolderView.isHidden = true
        targetHolderView = UIView(frame: CGRect(x: 0, y: 0, width: targetHolderRadius * 2,height: targetHolderRadius * 2))
        targetHolderView.center = center
        if targetTran {
            targetHolderView.backgroundColor = UIColor(white: 1, alpha: 0)
        } else {
            targetHolderView.backgroundColor = targetHolderColor
        }
        targetHolderView.asCircle()
        hiddenTargetHolderView.frame = targetHolderView.frame
        targetHolderView.transform = CGAffineTransform(scaleX: 1/ANI_TARGET_HOLDER_SCALE, y: 1/ANI_TARGET_HOLDER_SCALE) // Initial set to support animation
        addSubview(hiddenTargetHolderView)
        addSubview(targetHolderView)
    }
    
    /// Create a copy view of target view
    /// It helps us not to affect the original target view
    private func addTarget(at center: CGPoint) {
        targetCopyView = targetView.snapshotView(afterScreenUpdates: true)
        
        if shouldSetTintColor {
            targetCopyView.setTintColor(targetTintColor, recursive: true)
            
            if targetCopyView is UIButton {
                let button = targetView as! UIButton
                let buttonCopy = targetCopyView as! UIButton
                buttonCopy.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                buttonCopy.setTitleColor(targetTintColor, for: .normal)
                buttonCopy.isEnabled = true
            } else if targetCopyView is UIImageView {
                let imageView = targetView as! UIImageView
                let imageViewCopy = targetCopyView as! UIImageView
                imageViewCopy.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            } else if let imageViewCopy = targetCopyView.subviews.first as? UIImageView,
                let labelCopy = targetCopyView.subviews.last as? UILabel {
                let imageView = targetView.subviews.first as! UIImageView
                imageViewCopy.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                labelCopy.textColor = targetTintColor
            } else if let label = targetCopyView as? UILabel {
                label.textColor = targetTintColor
            }
        }
        
        let width = targetCopyView.frame.width
        let height = targetCopyView.frame.height
        targetCopyView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        targetCopyView.center = center
        targetCopyView.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(targetCopyView)
    }
    
    /// Configures and adds primary label view
    private func addInstructionView(at center: CGPoint) {
        instructionView = MaterialShowcaseInstructionView()
        
        instructionView.primaryTextAlignment = primaryTextAlignment
        instructionView.primaryTextFont = primaryTextFont
        instructionView.primaryTextSize = primaryTextSize
        instructionView.primaryTextColor = primaryTextColor
        instructionView.primaryText = primaryText
        
        instructionView.secondaryTextAlignment = secondaryTextAlignment
        instructionView.secondaryTextFont = secondaryTextFont
        instructionView.secondaryTextSize = secondaryTextSize
        instructionView.secondaryTextColor = secondaryTextColor
        instructionView.secondaryText = secondaryText
        
        instructionView.buttonText = buttonText
        instructionView.buttonVisable = buttonVisable
        instructionView.buttonTextColor = buttonTextColor
        instructionView.buttonBGColor = buttonBGColor
        instructionView.buttomRadius = buttonRadius
        instructionView.buttonTextSize = buttonTextSize
        
        // Calculate x position
        var xPosition = LABEL_MARGIN
        
        // Calculate y position
        var yPosition: CGFloat!
        
        // Calculate instructionView width
        var width : CGFloat
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = backgroundView.frame.width - xPosition
            
            if backgroundView.frame.origin.x < 0 {
                xPosition = abs(backgroundView.frame.origin.x) + xPosition
            } else if (backgroundView.frame.origin.x + backgroundView.frame.size.width >
                UIScreen.main.bounds.width) {
                width = backgroundView.frame.size.width - (xPosition*2)
            }
            if xPosition + width > backgroundView.frame.size.width {
                width = width - CGFloat(xPosition/2)
            }
            
            if getTargetPosition(target: targetView, container: containerView) == .above {
                yPosition = (backgroundView.frame.size.height/2) + TEXT_CENTER_OFFSET
            } else {
                yPosition = TEXT_CENTER_OFFSET + LABEL_DEFAULT_HEIGHT * 3
            }
        } else {
            if getTargetPosition(target: targetView, container: containerView) == .above {
                
                yPosition = center.y + TARGET_PADDING +  (targetView.bounds.height / 2 > self.targetHolderRadius ? targetView.bounds.height / 2 : self.targetHolderRadius)
                
            } else {
                let cvSize = CGSize(width: ceil(containerView.bounds.width), height: ceil(0))
                let pL = UILabel()
                pL.text = primaryText
                pL.font = UIFont(name: "SukhumvitSet-Bold", size: primaryTextSize)
                pL.lineBreakMode = NSLineBreakMode.byCharWrapping
                pL.frame = CGRect(x: 0,
                                  y: 0,
                                  width: containerView.frame.width - (xPosition + xPosition),
                                  height: 0)
//                pL.sizeToFit()
                let plSizeFit:CGSize = pL.sizeThatFits(cvSize)
                let plRect = CGSize(width: ceil(plSizeFit.width), height: ceil(plSizeFit.height))
                
                let dL = UILabel()
                dL.text = secondaryText
                dL.font = UIFont(name: "SukhumvitSet-Medium", size: secondaryTextSize)
                dL.lineBreakMode = NSLineBreakMode.byWordWrapping
                dL.frame = CGRect(x: 0,
                                   y: pL.frame.height + 4,
                                   width: containerView.frame.width - (xPosition + xPosition),
                                   height: 0)
                dL.sizeToFit()
                
                let bL = UIButton()
                bL.setTitle("   " + buttonText + "   ", for: .normal)
                bL.titleLabel?.font = UIFont(name: "SukhumvitSet-Bold", size: buttonTextSize)
                bL.frame = CGRect(x: 0,
                                  y: pL.frame.height + dL.frame.height + 16,
                                  width: containerView.frame.width - (xPosition + xPosition),
                                  height: 0)
                bL.sizeToFit()
                
//                yPosition = center.y - TEXT_CENTER_OFFSET - LABEL_DEFAULT_HEIGHT * 3
                yPosition = center.y - targetHolderRadius - pL.frame.height - LABEL_DEFAULT_HEIGHT - dL.frame.height - LABEL_DEFAULT_HEIGHT - bL.frame.height
            }
            
            width = containerView.frame.width - (xPosition + xPosition)
        }
        
        instructionView.frame = CGRect(x: xPosition,
                                       y: yPosition,
                                       width: width ,
                                       height: 0)
        if UIDevice.current.userInterfaceIdiom == .pad {
            backgroundView.addSubview(instructionView)
        } else {
            addSubview(instructionView)
        }
    }
    
    /// Handles user's tap
    private func tapGestureRecoganizer() -> UIGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MaterialShowcase.tapGestureSelector))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        return tapGesture
    }
    
    @objc public func tapGestureSelector() {
        completeShowcase()
    }
    
    /// Default action when dimissing showcase
    /// Notifies delegate, removes views, and handles out-going animation
    @objc public func completeShowcase(animated: Bool = true) {
        if delegate != nil && delegate?.showCaseDidDismiss != nil {
            delegate?.showCaseWillDismiss?(showcase: self)
        }
        if animated {
            targetRippleView.removeFromSuperview()
            UIView.animateKeyframes(withDuration: aniGoOutDuration, delay: 0, options: [.calculationModeLinear], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 3/5, animations: {
                    self.targetHolderView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                    self.backgroundView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.backgroundView.alpha = 0
                })
                UIView.addKeyframe(withRelativeStartTime: 3/5, relativeDuration: 2/5, animations: {
                    self.alpha = 0
                })
            }, completion: { (success) in
                // Recycle subviews
                self.recycleSubviews()
                // Remove it from current screen
                self.removeFromSuperview()
            })
        } else {
            // Recycle subviews
            self.recycleSubviews()
            // Remove it from current screen
            self.removeFromSuperview()
        }
        if delegate != nil && delegate?.showCaseDidDismiss != nil {
            delegate?.showCaseDidDismiss?(showcase: self)
        }
    }
    
    private func recycleSubviews() {
        subviews.forEach({$0.removeFromSuperview()})
    }
}

// MARK: - Private helper methods
extension MaterialShowcase {
    
    /// Defines the position of target view
    /// which helps to place texts at suitable positions
    enum TargetPosition {
        case above // at upper screen part
        case below // at lower screen part
    }
    
    /// Detects the position of target view relative to its container
    func getTargetPosition(target: UIView, container: UIView) -> TargetPosition {
        let center = calculateCenter(at: targetView, to: container)
        if center.y < container.frame.height / 2{
            return .above
        } else {
            return .below
        }
    }
    
    // Calculates the center point based on targetview
    func calculateCenter(at targetView: UIView, to containerView: UIView) -> CGPoint {
        let targetRect = targetView.convert(targetView.bounds , to: containerView)
        return targetRect.center
    }
    
    // Gets all UIView from TabBarItem.
    func orderedTabBarItemViews(of tabBar: UITabBar) -> [UIView] {
        let interactionViews = tabBar.subviews.filter({$0.isUserInteractionEnabled})
        return interactionViews.sorted(by: {$0.frame.minX < $1.frame.minX})
    }
}
