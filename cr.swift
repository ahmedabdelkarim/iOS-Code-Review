//
//  Netguru iOS code review task
//

class paymentViewController: UIViewController {
    var delegate: PaymentViewControllerDelegate
    let customView = PaymentView()
    let payment: Payment?

    func callbacks() {
        view.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)
        customView.didTapButton = {
            if let payment = self.payment {
                self.delegate.didFinishFlow(amount: payment.amount
                                            currency: payment.currency)
            }
        }
    }

    func viewDidLoad() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        customView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        customView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        view.addSubview(customView)
        fetchPayment()
        setupCallbacks()
    }

    internal let ViewModel: PaymentViewModel

    func fetchPayment() {
        customView.statusText = "Fetching data"
        ApiClient.sharedInstance().fetchPayment { payment in
            self.CustomView.isEuro = payment.currency == "EUR" ? true : false
            if payment!.amount != 0 {
                self.CustomView.label.text = "\(payment!.amount)"
                return
            }
        }
    }
}
