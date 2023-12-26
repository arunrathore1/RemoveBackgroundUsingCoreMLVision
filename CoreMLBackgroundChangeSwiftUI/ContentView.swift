//
//  ContentView.swift
//  CoreMLBackgroundChangeSwiftUI
//
//  Created by Arun Rathore on 26/12/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var removebackground: RemoveBackground = RemoveBackground()
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Image(uiImage: removebackground.inputImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                    Spacer()
                    Image(uiImage: removebackground.outputImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                }

                Button(action: {removebackground.runVisionRequest()}, label: {
                    Text("Segmentation")
                })
                .padding()

            }.ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct GradientPoint {
    var location: CGFloat
    var color: UIColor
}
