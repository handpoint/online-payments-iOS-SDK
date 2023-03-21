import XCTest
@testable import Gateway

final class GatewayTests: XCTestCase {
    
    let gatewayDirect = Gateway("https://gateway.example.com/direct/", "merchant_id_here", "merchant_secret_here")
    let gatewayHosted = Gateway("https://gateway.example.com/hosted/", "merchant_id_here", "merchant_secret_here")
    
    func testDirectRequest() {
            
        let request = [
            "action": "SALE",
            "amount": "2199",
            "cardCVV": "356",
            "cardExpiryMonth": "12",
            "cardExpiryYear": "23",
            "cardNumber": "4929421234600821",
            "countryCode": "826", // GB
            "currencyCode": "826", // GBP
            "customerAddress": "Flat 6 Primrose Rise 347 Lavender Road Northampton",
            "customerName": "Tester",
            "customerEmail": "user@example.com",
            "customerPostCode": "NN17 8YG",
            "orderRef": "iOS-SDK-TEST-DIRECT",
            "type": "1" // E-commerce
        ]
        
        let expectation = self.expectation(description: "asynchronous request")
        var response: [String: String]?
        
        self.gatewayDirect.directRequest(request) {
            response = $0
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 60.0, handler: nil)
        
        if let response = response {
            XCTAssertEqual((response["responseCode"]! as NSString).integerValue, Gateway.RC_SUCCESS)
            XCTAssertEqual(response["amountReceived"], request["amount"])
            XCTAssertEqual(response["state"], "captured")
        } else {
            XCTFail("Fail")
        }
    }
    
    func testHostedRequest() {
        
        do {
            
            var request = [
                "action": "SALE",
                "amount": "2399",
                "cardExpiryDate": "1223",
                "cardNumber": "4929 4212 3460 0821",
                "countryCode": "826", // GB
                "currencyCode": "826", // GBP
                "merchantID": "merchant_id_here",
                "orderRef": "T004",
                "transactionUnique": "55f025addd3c2",
                "type": "1" // E-commerce
            ]
            
            let html = try self.gatewayHosted.hostedRequest(request, options: ["submitText": "Confirm & Pay"])
            
            let signature = self.gatewayHosted.sign(request, secret: self.gatewayHosted.merchantSecret, partial: true)
            request["signature"] = signature
            
            var assertion = "<form method=\"post\"  action=\"" + self.gatewayHosted.gatewayUrl.absoluteString + "\">\n"
            for item in Array(request.keys).sorted() {
                assertion += "<input type=\"hidden\" name=\"" + item + "\" value=\"" + request[item]! + "\" />\n"
            }
            assertion += "<input  type=\"submit\" value=\"Confirm &amp; Pay\">\n</form>\n"
            
            XCTAssertEqual(html, assertion)
            
        } catch {
            XCTFail("Fail")
        }
        
    }
    
}

