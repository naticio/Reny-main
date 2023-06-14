//
//  SentApplication.swift
//  Reny
//
//  Created by Nat-Serrano on 1/7/22.
//

import SwiftUI  

struct SentApplication: View {
    @ObservedObject var userData: UserData
    @EnvironmentObject var plaid : PlaidAPI
    @ObservedObject var viewC : ViewController
    @Environment(\.presentationMode) var presentationMode
    
    var listing : Listings
    
    @Binding var plaidDoneLess30DaysAgo: Bool
    
    @State var progressValue: Float = 0.0
    
    //@State var scenario: String
    
    var accessToken = UserDefaults.standard.value(forKey: "access_token")
    @State private var progress = 0.2
    @State var monthlyRent : Double
    
    //var dummyIncome = 43000.0
    
    var body: some View {
        
        //if there was NO PLAID FLOW
        //if plaidDoneLess30DaysAgo == true {
        if userData.scenario == "PlaidDoneLessThan30DaysAgo" {
            
            let totalIncomeYear = ((UserDefaults.standard.double(forKey: "total_earnings") * -1)*100)/70
            let fortyXMonthlyRent = Double(monthlyRent * 40)
            
//            let totalEarnedPositive = UserDefaults.standard.double(forKey: "total_earnings") * -1
//            let totalRentYear = Double(monthlyRent * 12)
//            let fortyPercentYearIncome = totalEarnedPositive * 0.4
//
            
            if (totalIncomeYear > fortyXMonthlyRent) {
                //APPROVED
                Spacer()
                
                Image(systemName: "star").foregroundColor(.yellow)
                    .padding()
                    .frame(width: 500, height: 500, alignment: .center)
                
                Text("You're a suitable tenant").foregroundColor(.green)
                    .font(.system(size:20, weight: .semibold))
                    .padding()
                
                Text("My annual income: $\(totalIncomeYear, specifier: "%.0f") is MORE than 40x monthly rent: $ \(fortyXMonthlyRent, specifier: "%.0f")")
                    .padding()
                
                Text("We'll notify you via text if the Landlord selected your application").font(.body).padding()
                
                //button submit contract
                ZStack {
                    Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                    Button {
                        //send to sign contract views
                        ///TBD TBD TBD
                        /// but this time only change the status of the listing to "PENDING APPLICATION"
                        /// and block it for everybody else (they cannot apply anymore)
                    } label: {
                        //OK
                        Text("Submit contract now").foregroundColor(.white)
                    }
                }.padding(.horizontal, 20)
                
                //button dismiss
                ZStack {
                    Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                    Button {
                        //dismiss sheet
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        //OK
                        Text("Not now").foregroundColor(.white)
                    }
                }.padding(.horizontal, 20)
                
                
            } else {
                //annual rent > 40% of my salary
                Spacer()
                
                Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                    .padding()
                    .frame(width: 500, height: 500, alignment: .center)
                
                Text("application rejected").foregroundColor(.red).bold()
                    .font(.system(size:25, weight: .semibold))
                    .padding()
                
                Text("40x monthly rent: $ \(fortyXMonthlyRent, specifier: "%.0f") is MORE than my yearly income: \(totalIncomeYear, specifier: "%.0f")")
                    .padding()
                

                
                //button dismiss
                ZStack {
                    Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                    Button {
                        //dismiss sheet
                        presentationMode.wrappedValue.dismiss()
                        
                        //call withdraw button
                        UserDefaults.standard.set(nil, forKey: "current_application")
                        
                    } label: {
                        //OK
                        Text("OK").foregroundColor(.white)
                    }
                }.padding(.horizontal, 20)
                
                //button asset report
                /*
                ZStack {
                    Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                    Button {
                        userData.getAssetReportPDF()
                        //dismiss sheet
                        presentationMode.wrappedValue.dismiss()
                        
                        //call withdraw button
                        UserDefaults.standard.set(nil, forKey: "current_application")
                        
                    } label: {
                        //OK
                        Text("get your report").foregroundColor(.white)
                    }.disabled(UserDefaults.standard.string(forKey: "asset_report_token") == nil)
                }.padding(.horizontal, 20)
                */
            
            }
            
            Spacer()
        } else {
            //if there WAS PLAID FLOW
            if viewC.PladFlowFinishedWithAccessToken == false {
                
                ProgressBar(progress: self.$progressValue)
                    .frame(width: 150.0, height: 150.0)
                    .padding(40.0)
                    .onAppear() {
                        self.progressValue = 1.0
                    }
                
            } else {
                VStack {
                    if userData.hasLoaded {
                        
                        let totalIncomeYear = ((userData.totalEarned * -1)*100)/70
                        //let totalRentYear = Double(monthlyRent * 12)
                        let fortyXMonthlyRent = Double(monthlyRent * 40)
                        //let fortyPercentYearIncome = totalIncomeYear * 0.4
                        
                        if (totalIncomeYear > fortyXMonthlyRent) {
                            
                            Spacer()
                            
                            Image(systemName: "star").foregroundColor(.yellow)
                                .padding()
                                .frame(width: 500, height: 500, alignment: .center)
                            
                            Text("You're a suitable tenant").foregroundColor(.green)
                                .font(.system(size:20, weight: .semibold))
                                .padding()
                            
                            Text("My annual income: $\(totalIncomeYear, specifier: "%.0f") is MORE than 40x monthly rent: $ \(fortyXMonthlyRent, specifier: "%.0f")")
                                .padding()
        
                            
                            Text("We'll notify you via text if the Landlord selected your application").font(.body).padding()
                            
                            //button submit contract
                            ZStack {
                                Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                                Button {
                                    //send to sign contract views
                                    ///TBD TBD TBD
                                    /// but this time only change the status of the listing to "PENDING APPLICATION"
                                    /// and block it for everybody else (they cannot apply anymore)
                                } label: {
                                    //OK
                                    Text("Submit contract now").foregroundColor(.white)
                                }
                            }.padding(.horizontal, 20)
                            
                            //button dismiss
                            ZStack {
                                Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                                Button {
                                    //dismiss sheet
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    //OK
                                    Text("Not now").foregroundColor(.white)
                                }
                            }.padding(.horizontal, 20)
                            
                            //button asset report
                            ZStack {
                                Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                                Button {
                                    userData.getAssetReportPDF()
                                    //dismiss sheet
                                    presentationMode.wrappedValue.dismiss()
                                    
                                    //call withdraw button
                                    UserDefaults.standard.set(nil, forKey: "current_application")
                                    
                                } label: {
                                    //OK
                                    Text("get your report").foregroundColor(.white)
                                }
                            }.padding(.horizontal, 20)
                            
                        } else {
                            Spacer()
                            Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                                .padding()
                                .frame(width: 500, height: 500, alignment: .center)
                            
                            Text("Application Rejected").foregroundColor(.red).bold()
                                .font(.system(size:25, weight: .semibold))
                                .padding()
                            
                            Text("40x monthly rent: $ \(fortyXMonthlyRent, specifier: "%.0f") is MORE than my yearly income: \(totalIncomeYear, specifier: "%.0f")")
                                .padding()
                            
                            
                            //button dismiss
                            ZStack {
                                Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                                Button {
                                    //dismiss sheet
                                    presentationMode.wrappedValue.dismiss()
                                    
                                    //call withdraw button
                                    UserDefaults.standard.set(nil, forKey: "current_application")
                                    
                                } label: {
                                    //OK
                                    Text("OK").foregroundColor(.white)
                                }
                            }.padding(.horizontal, 20)
                            
                            //button asset report
                            ZStack {
                                Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                                Button {
                                    userData.getAssetReportPDF()
                                    //dismiss sheet
                                    presentationMode.wrappedValue.dismiss()
                                    
                                    //call withdraw button
                                    UserDefaults.standard.set(nil, forKey: "current_application")
                                    
                                } label: {
                                    //OK
                                    Text("get your report").foregroundColor(.white)
                                }
                            }.padding(.horizontal, 20)
                        }
                        
                        Spacer()
                        
                    }
                }
                .onAppear(){
                    //for scenario that I didn't have an access token and I am waiting for async to resolve
                    if userData.scenario != "PlaidDoneLessThan30DaysAgo" {
                        userData.load() //get user data when I DID HAVE the link flow
                    }
                    
                    //why do I need to keep all the leads in memory?????
                    //UserServic.shared.user.leads_address.append(listing.address!.streetAddress ?? "")
                    
                    ProgressBar(progress: self.$progressValue)
                        .frame(width: 150.0, height: 150.0)
                        .padding(40.0)
                        .onAppear() {
                            self.progressValue = 1.0
                        }
                }
                
                //            .task {
                //
                //                    userData.load()
                //            }
            }
        }
        
        
    }
    
    func incrementProgress() {
        let randomValue = Float([0.012, 0.022, 0.034, 0.016, 0.11].randomElement()!)
        self.progressValue += randomValue
    }
    
    
}

struct GaugeProgressStyle: ProgressViewStyle {
    var strokeColor = Color.blue
    var strokeWidth = 25.0
    
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        
        return ZStack {
            Circle()
                .trim(from: 0, to: CGFloat(fractionCompleted))
                .stroke(strokeColor, style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

struct ProgressBar: View {
    @Binding var progress: Float
    var color: Color = Color.blue
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.2)
                .foregroundColor(Color.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut(duration: 2.0))
            
            //            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
            //                .font(.largeTitle)
            //                .bold()
        }
    }
}

//struct SentApplication_Previews: PreviewProvider {
//    static var previews: some View {
//        SentApplication(userData: UserData(), viewC: ViewController(), listing: ListingsZillow())
//    }
//}

