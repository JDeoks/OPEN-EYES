//
//  ContentView.swift
//  CounterConnect
//
//  Created by 서정덕 on 2023/04/06.
//

import CoreML
import SwiftUI

struct ContentView: View {
    // ViewModelPhone 인스턴스를 생성
    var model = ViewModelPhone()
    /// 문서: 0, 물체: 1
    @State private var mode = 0
    /// 이미지 피커를 보여줄지 여부를 결정하는 State
    @State private var showingImagePicker = false
    /// 선택한 이미지를 저장하는 State
    @State private var inputImage: UIImage?

    
    // reachable: 연결 상태를 나타내는 문자열 변수. 초기값은 "No"
    @State var reachable = "No"
    
    // messageText: 사용자가 입력할 메시지를 저장하는 문자열 변수
    @State var messageText = ""
    
    var body: some View {
        VStack{
            Image("OpenEyes16_9")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .padding([.top ,.bottom],10)
            
            Picker(selection: $mode, label: Text("모드선택")) {
                Text("문서 인식")
                    .tag(0)
                Text("물체 인식")
                    .tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing],40)
            
//            // 연결 상태를 표시
//            Text("Reachable \(reachable)")
//
//            // "Update" 버튼: 클릭 시 Apple Watch와의 연결 상태를 확인하고 reachable 변수를 업데이트
//            Button(action: {
//                if self.model.session.isReachable {
//                    self.reachable = "Yes"
//                } else {
//                    self.reachable = "No"
//                }
//
//            }) {
//                Text("Update")
//            }
            
            Spacer()

            Button(action: {
                // 이미지 피커 불러오기
                showingImagePicker = true
            }) {
                Image(systemName: "camera")
                    .resizable() // 크기 조정 가능하도록 resizable modifier 추가
                    .scaledToFit() // 이미지 비율 유지
                    .foregroundColor(.black) // 검은색 틴트 컬러 적용
                    .frame(width: 150) // 크기 조정
            }

            if let inputImage = inputImage {
                // 선택한 이미지가 있으면 화면에 표시
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .padding(60)
            }
            else {
                Spacer()
            }
            Spacer()


//            // 사용자가 메시지를 입력할 수 있는 텍스트 필드
//            TextField("Input your message", text: $messageText)
//
//            // "Send Message" 버튼: 클릭 시 입력한 메시지를 Apple Watch로 전송
//            Button(action: {
//                self.model.session.sendMessage(["message": self.messageText], replyHandler: nil) { (error) in
//                    print(error.localizedDescription)
//                }
//            }) {
//                Text("Send Message")
//            }
        }
        // .sheet를 .fullScreenCover로 변경
        // present 여부를 $showingImagePicker로 결정함
        // .sheet나 .fullScreenCover를 사용하면, 해당 뷰를 닫을 때 자동으로 isPresented와 연결된 변수 false로 설정
        .fullScreenCover(isPresented: $showingImagePicker, onDismiss: loadImage) {
            // 이미지 피커를 표시
            ImagePicker(image: $inputImage)
        }
    }

    /// 이미지가 선택되고, ImagePicker가 dismiss되면 실행되는 함수
    func loadImage() {
        // 이미지를 저장하거나 처리하려면 여기에서 수행
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    /// 뷰의 presentation 상태에 접근하는 데 사용된다. 뷰를 닫는 동작을 처리하기 위해 사용
    @Environment(\.presentationMode) var presentationMode
    /// 선택한 이미지를 저장하는  변수. 다른 뷰와 값이 동기화되어야 하므로 @Binding이 사용됨
    @Binding var image: UIImage?

    // UIViewControllerRepresentable에 정의되어 있음
    // UIViewController 객체가 생성됨과 동시에 호출, Coordinator 객체를 생성
    func makeCoordinator() -> Coordinator {
        // init 메서드에 자신(ImagePicker)넣음
        Coordinator(self)
    }

    // UIViewControllerRepresentable을 채택한 뷰가 생성될 때 호출
    // UIImagePickerController를 생성하고 반환
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // delegate를
        picker.delegate = context.coordinator
        // picker.sourceType = .camera
        picker.sourceType = .photoLibrary // 앨범에서 이미지를 선택하도록 설정
        return picker
    }

    // 이미지 피커를 업데이트하는 함수 (본 예제에서는 필요하지 않음)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    // UIImagePickerControllerDelegate와 UINavigationControllerDelegate를 구현하는 Coordinator 클래스
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // 이미지가 선택되면 호출되는 함수
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
