//
//  DirectPaymentViewController.swift

import UIKit
import SwiftUI
import Gateway

class DirectPaymentViewController: UIViewController {

    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var cardCVV: UITextField!
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var cardExpiryDate: UITextField!
    @IBOutlet weak var customerAddress: UITextField!
    @IBOutlet weak var customerPostCode: UITextField!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    @State var showingAlert: Bool = false
    
    let DIRECT_URL = Bundle.main.object(forInfoDictionaryKey: "direct_url")
    let MERCHANT_ID = Bundle.main.object(forInfoDictionaryKey: "merchant_id")
    let MERCHANT_SECRET = Bundle.main.object(forInfoDictionaryKey: "merchant_secret")
    
    var gateway: Gateway
    
    required init?(coder aDecoder: NSCoder) {
        gateway = Gateway(DIRECT_URL as! String, MERCHANT_ID as! String, MERCHANT_SECRET as? String)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progress.hidesWhenStopped = true
    }

    @IBAction func sendPayment(_ sender: UIButton) {
        progress.startAnimating()
        let amountText: String = amount.text ?? "0"
        let amountInt: Int = Int(Double(amountText)! * 100)
        let request = [
            "action" : "SALE",
            "amount" : "\(amountInt)",
            "cardNumber" : "\((cardNumber.text ?? ""))",
            "cardExpiryDate" : "\((cardExpiryDate.text ?? ""))",
            "cardCVV" : "\((cardCVV.text ?? ""))",
            "customerAddress" : "\((customerAddress.text ?? ""))",
            "customerPostCode" : "\((customerPostCode.text ?? ""))",
            "countryCode" : "826",
            "currencyCode" : "826",
            "type" : "1",
            "customerEmail" : "tester@example.com",
            "orderRef" : "test001",
        ]
        
        gateway.directRequest(request) { returnValue in
            if let returnValue = returnValue {
                print((returnValue["acquirerResponseMessage"] ?? "") as String)
                print((returnValue["vcsResponseMessage"] ?? "") as String)
                print((returnValue["state"] ?? "") as String)
                DispatchQueue.main.async {
                    self.progress.stopAnimating()
                    self.showAlert(title: returnValue["state"] ?? "Payment Transaction", message: returnValue["acquirerResponseMessage"] ?? "Transaction failed")
                }
            } else {
                print("Failed to get response")
                DispatchQueue.main.async {
                    self.progress.stopAnimating()
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
            print("Tapped Dismiss")
        }))
        present(alert, animated: true)
    }
}
