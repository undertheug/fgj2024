import SpriteKit

class DialogManager {
    private let dialogBox: SKLabelNode
    private let continueButton: (() -> Void)
    private let backButton: (() -> Void)
    private let dialogContainer: SKSpriteNode

    init(dialogBox: SKLabelNode, continueButtonAction: @escaping () -> Void, backButtonAction: @escaping () -> Void) {
        self.dialogContainer = SKSpriteNode()  // Initialize dialogContainer
        self.dialogBox = dialogBox
        self.continueButton = continueButtonAction
        self.backButton = backButtonAction

        // Hide the components initially
        hideComponents()
    }

    func showText(_ text: String) {
        // Display text in the dialogBox
        dialogBox.text = text

        // Show continueButton and backButton
        showComponents()
    }

    func showComponents() {
        dialogContainer.isHidden = false  // Show the entire container
    }

    func hideComponents() {
        // Hide all components
        dialogBox.isHidden = true
        dialogContainer.isHidden = true
    }

    func continueDialog() {
        // Implement logic to handle continuing the dialog
        continueButton()
    }

    func goBackInDialog() {
        // Implement logic to handle going back in the dialog
        backButton()
    }

    func handleTap(at location: CGPoint) {
        // Implement logic to handle touches
        // You may want to check if the touch is within the bounds of your buttons or dialog components
        // and call the corresponding methods
    }
}
