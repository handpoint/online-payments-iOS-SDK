//
//  HostedPaymentViewController.swift

import UIKit
import SwiftUI
import WebKit
import Gateway

class HostedPaymentViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    private var observation: NSKeyValueObservation?
    private var observation2: NSKeyValueObservation?
    
    let HOSTED_URL = Bundle.main.object(forInfoDictionaryKey: "hosted_url")
    let MERCHANT_ID = Bundle.main.object(forInfoDictionaryKey: "merchant_id")
    let MERCHANT_SECRET = Bundle.main.object(forInfoDictionaryKey: "merchant_secret")
    let REDIRECT_URL = Bundle.main.object(forInfoDictionaryKey: "redirect_url")
    
    var gateway: Gateway
    
    required init?(coder aDecoder: NSCoder) {
        gateway = Gateway(HOSTED_URL as! String, MERCHANT_ID as! String, MERCHANT_SECRET as? String)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progress.hidesWhenStopped = true
        
        sendPayment()
        
        observation = webView.observe(\WKWebView.estimatedProgress, options: .new) { _, change in
            let value = change.newValue ?? 0
            if(value == 1.0){
                DispatchQueue.main.async {
                    self.progress.stopAnimating()
                }
            }else{
                if(!self.progress.isAnimating){
                    DispatchQueue.main.async {
                        self.progress.startAnimating()
                    }
                }
            }
        }
        observation2 = webView.observe(\WKWebView.url, options: .new) { _, change in
            let value = change.newValue
            DispatchQueue.main.async {
                self.progress.startAnimating()
            }
            if((value) != nil && value == URL(string: self.REDIRECT_URL as! String)){
                print("Payment transaction completed");
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    deinit {
        self.observation = nil
        self.observation2 = nil
    }
    
    func sendPayment() {
        progress.startAnimating()
        let amountText: String = "21.99"
        let amountInt: Int = Int(Double(amountText)! * 100)
        let request: [String: String] = [
            "action" : "SALE",
            "amount" : "\(amountInt)",
            "countryCode" : "826",
            "currencyCode" : "826",
            "type" : "1",
            "customerEmail" : "user@example.com",
            "customerAddress" : "Flat 6 Primrose Rise 347 Lavender Road Northampton",
            "customerPostCode" : "NN17 8YG",
            "orderRef" : "test001",
            "redirectURL" : REDIRECT_URL as! String,
            //"remoteAddress" : "0.0.0.0",
        ]
        
        guard let form = try? gateway.hostedRequest(request) else {
            print("Failed to generate payment form")
            return
        }
        DispatchQueue.main.async {
            self.progress.startAnimating()
            self.webView.loadHTMLString("<!DOCTYPE html><html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><title>Payment Example</title></head><body>"+form+"</body></html>", baseURL: nil)
        }
    }
    
}
