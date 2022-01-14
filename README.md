# Netguru iOS code review

## Code review comments:

Line 4:
Need to add "import UIKit" for UIViewController and other UI related code to work.

Line 5:
Class name should begin with a capital letter (PascalCase).
Arranging code in groups using "// MARK: - " will make it better and more easy to maintain and read.

Line 6:
Delegates should be weak to avoid reference cycles and memory leaks -> weak var delegate: PaymentViewControllerDelegate?
But make sure that "PaymentViewControllerDelegate" inherits from AnyObject because it must be guaranteed to be reference type to allow using weak.

Line 7:
Possible to make paymentView injectable by making it var.

Line 8:
Defining payment as optional constant (let) makes it always nil. It should be var to allow setting from outside the class, or assigning it injected in initializer.

Line 10:
Method name should be a verb sentence like "setCallbacks".

Line 11:
Possible to simplify "UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)" to "UIColor.white" or even ".white".

Line 12:
Should avoid reference cycles by using capture list with weak self like this:
customView.didTapButton = { [weak self] in
And referring to "self?" instead of "self" inside the closure block.

Line 14:
	1.	When setting delegate weak, it have to be optional. So here we need to use "delegate?" instead of "delegate".
	2.	Expected ',' separator after "payment.amount".


Line 20:
"viewDidLoad" declaration requires an 'override' keyword because it is an override of viewDidLoad that's in the super class UIViewController.

Line 21:
Note that showing navigation bar here may need to be inverted when this screen disappears.
If this is the case, we can show it in "viewDidLoad" or "viewDidAppear" and hide it in "viewDidDisappear" based on the required behavior.

Line 22:
1. To constraint a view, first disable translate auto-resizing to constraints and add as subview like this:
customView.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(customView)
2. Constraints are defined but not activated. It ca be activated by appending ".isActive = true" to the end.


Line 26:
1. Method name has to match the name of the defined method.
2. It's better to assign callbacks before executing related code, so you may need to call "setupCallbacks" before "fetchPayment".

Line 29:
1. Can simplify by removing "internal" because it is the default access modifier.
2. Need to be "var" not "let" to allow setting/injecting it.
3. Variable name should start with a lowercase character (camelCase).
4. Should move business logic related code to the "PaymentViewModel" and use it in this file.

Recommended definition like this: var viewModel: PaymentViewModel?

Line 33:
Should avoid reference cycles by using capture list.
{ [weak self] payment in
And referring to "self?" instead of "self" inside the closure block.

Line 34:
1. It is "customView" with small 'c' not "CustomView".
2. Can simplify by removing " ? true : false" because payment.currency == "EUR" already returns Bool value.

Line 35:
1. Cannot force unwrap value of non-optional type 'Payment', can be fixed by removing '!'.
2. Should handle it in a way that covers edge cases, for example handling when value is greater than zero in addition to when it's less than zero.

Line 36:
1. It is "customView" with small 'c' not "CustomView".
2. Should  not force unwrap value of "payment", can be fixed by using optional binding above.
3. Also here need to call UI changes in the main dispatch queue because it's called from background.
DispatchQueue.main.async {
    self.CustomView.label.text = "\(payment!.amount)"
}

Line 37:
May need to update customView.statusText to indicate the current status before return.


## Improved version of cr.swift:

```
import UIKit

class PaymentViewController: UIViewController {
    // MARK: - Properties
    var viewModel: PaymentViewModel?
    weak var delegate: PaymentViewControllerDelegate?
    var customView = PaymentView()
    var payment: Payment?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        addCustomView()
        setCallbacks()
        fetchPayment()
    }
    
    // MARK: - Methods
    private func addCustomView() {
        customView.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(customView)
        customView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setCallbacks() {
        view.backgroundColor = .white
        
        customView.didTapButton = { [weak self] in
            if let payment = self?.payment {
                self?.delegate?.didFinishFlow(amount: payment.amount, currency: payment.currency)
            }
        }
    }
    
    private func fetchPayment() {
        customView.statusText = "Fetching data"
        
        ApiClient.sharedInstance().fetchPayment { [weak self] payment in
            guard let payment = payment else {
                // TODO: - handle
                return
            }
            
            self?.customView.isEuro = payment.currency == "EUR"
            if payment.amount > 0 {
                self?.customView.label.text = "\(payment.amount)"
                customView.statusText = ""
                return
            }
            else {
                // TODO: - handle
            }
        }
    }
}
```
