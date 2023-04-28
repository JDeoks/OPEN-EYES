//
//  ContentView.swift
//  CounterConnect Watch App
//
//  Created by 서정덕 on 2023/04/06.
//

import SwiftUI
import WatchKit



struct ContentView: View {
    
    /// 뷰모델 인스턴스 생성
    @ObservedObject var model = ViewModelWatch()
    /// 받은 일반 문자열 저장
    @State var str: String = "기본"
    // 크라운입력값 받는 변수
    @State private var crownValue = 0.0
    /// 현재 읽고있는 글자의 인덱스
    @State var crownIdx: Int = 0
    /// 마지막 크라운 입력값. 변화량 비교위해 필요
    @State var lastCrown = 0.0
    /// 변환한 이진 문자열
    @State var brl2DArr: [[Int]] = [[0,1,0,1,0,1]]
    /// 마지막으로 터치한 dot 정보
    @State var lastTouch: Int = -1


    var body: some View {
        VStack{
            Text("\(str)\(crownIdx): \(String(str[crownIdx]))")
            
            LazyVGrid(columns: [
                GridItem(.fixed(50)), GridItem(.fixed(50))
            ], spacing: 10) {
                ForEach(0..<3) { row in
                    ForEach(0..<2) { col in
                        let index = row + (col * 3)
                        GeometryReader { geo in
                            let width = geo.size.width / 2
                            let height = geo.size.height / 3
                            
                            Text("\(index + 1)")
                                .font(.largeTitle)
                                .opacity(brl2DArr[crownIdx][5 - index] == 1 ? 1 : 0.4)
                                .frame(width: width, height: height)
                                .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
                                .gesture(DragGesture(minimumDistance: 0)
                                    .onChanged({ value in
                                        /// 터치 좌표
                                        let loc: CGPoint = value.location
                                        if isInside(loc, geo: geo) &&  brl2DArr[crownIdx][5 - index] == 1{
                                            print(index + 1)
                                        }
                                    })
                                )
                                
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
            }

            
        }
        // 워치 통신 감지.  변화를 감지할 변수이름에 $를 붙여 감시, 파라미터는 변화한 값
        .onReceive(self.model.$messageText) { message in
            self.str = message
            print(message)
            if message != "" {
                brl2DArr = convert(str: message)
                print(brl2DArr)
            }
        }
        // 크라운 입력 받기
        // 뷰에 포커스를 설정할 수 있으며, Digital Crown 회전 이벤트가 발생할 때마다 이를 감지하고 처리한다.
        .focusable()
        // $crownValue 위치에 값 받을 변수 넣음
        .digitalCrownRotation($crownValue) { DigitalCrownEvent in
            // DigitalCrownEvent.offset 으로 크라운값 받기 가능
            if crownValue > lastCrown + 20 {
                lastCrown = crownValue
                if crownIdx < brl2DArr.count - 1 {
                    //진동
                    crownIdx += 1
                }

            }
            else if crownValue <  lastCrown - 20 {
                lastCrown = crownValue
                if crownIdx > 0 {
                    //진동
                    crownIdx -= 1
                }
            }
//                crownIndex = Int(DigitalCrownEvent.offset)/10
        }
    }
    /// 일반 String 받아서 점자 Int arr로 반환. 입력: "Hello", 출력: [[0,1,1,0,0,0],[0,0,0,1,1,0]]
    func convert(str string: String) -> [[Int]]{
        /// 소문자로 저장된 일반 String
        let str = string.lowercased()
        /// 반환할 배열, ["100011", "010010"]의 형식을 갖고있음
        var returnValue: [[Int]] = []
        /// [글자: 점자] 딕셔너리
        let eng2Braille: [Character: Character] = [
                "a": "⠁", "b": "⠃", "c": "⠉", "d": "⠙",
                "e": "⠑", "f": "⠋", "g": "⠛", "h": "⠓",
                "i": "⠊", "j": "⠚", "k": "⠅", "l": "⠇",
                "m": "⠍", "n": "⠝", "o": "⠕", "p": "⠏",
                "q": "⠟", "r": "⠗", "s": "⠎", "t": "⠞",
                "u": "⠥", "v": "⠧", "w": "⠺", "x": "⠭",
                "y": "⠽", "z": "⠵",
                " ": "⠀", ".": "⠲", ",": "⠂",
                "?": "⠦", "!": "⠖", ";": "⠆",
                ":": "⠒", "-": "⠤", "/": "⠌",
                "0": "⠴", "1": "⠂", "2": "⠆", "3": "⠒",
                "4": "⠲", "5": "⠢", "6": "⠖", "7": "⠶",
                "8": "⠦", "9": "⠔"
            ]
        ///  [점자: 이진수] 딕셔너리
        let braille2IntArr: [Character: [Int]] = [
            "⠀": [0,0,0,0,0,0], "⠁": [0,0,0,0,0,1],
            "⠂": [0,0,0,0,1,0], "⠃": [0,0,0,0,1,1],
            "⠄": [0,0,0,1,0,0], "⠅": [0,0,0,1,0,1],
            "⠆": [0,0,0,1,1,0], "⠇": [0,0,0,1,1,1],
            "⠈": [0,0,1,0,0,0], "⠉": [0,0,1,0,0,1],
            "⠊": [0,0,1,0,1,0], "⠋": [0,0,1,0,1,1],
            "⠌": [0,0,1,1,0,0], "⠍": [0,0,1,1,0,1],
            "⠎": [0,0,1,1,1,0], "⠏": [0,0,1,1,1,1],
            "⠐": [0,1,0,0,0,0], "⠑": [0,1,0,0,0,1],
            "⠒": [0,1,0,0,1,0], "⠓": [0,1,0,0,1,1],
            "⠔": [0,1,0,1,0,0], "⠕": [0,1,0,1,0,1],
            "⠖": [0,1,0,1,1,0], "⠗": [0,1,0,1,1,1],
            "⠘": [0,1,1,0,0,0], "⠙": [0,1,1,0,0,1],
            "⠚": [0,1,1,0,1,0], "⠛": [0,1,1,0,1,1],
            "⠜": [0,1,1,1,0,0], "⠝": [0,1,1,1,0,1],
            "⠞": [0,1,1,1,1,0], "⠟": [0,1,1,1,1,1],
            "⠠": [1,0,0,0,0,0], "⠡": [1,0,0,0,0,1],
            "⠢": [1,0,0,0,1,0], "⠣": [1,0,0,0,1,1],
            "⠤": [1,0,0,1,0,0], "⠥": [1,0,0,1,0,1],
            "⠦": [1,0,0,1,1,0], "⠧": [1,0,0,1,1,1],
            "⠨": [1,0,1,0,0,0], "⠩": [1,0,1,0,0,1],
            "⠪": [1,0,1,0,1,0], "⠫": [1,0,1,0,1,1],
            "⠬": [1,0,1,1,0,0], "⠭": [1,0,1,1,0,1],
            "⠮": [1,0,1,1,1,0], "⠯": [1,0,1,1,1,1],
            "⠰": [1,1,0,0,0,0], "⠱": [1,1,0,0,0,1],
            "⠲": [1,1,0,0,1,0], "⠳": [1,1,0,0,1,1],
            "⠴": [1,1,0,1,0,0], "⠵": [1,1,0,1,0,1],
            "⠶": [1,1,0,1,1,0], "⠷": [1,1,0,1,1,1],
            "⠸": [1,1,1,0,0,0], "⠹": [1,1,1,0,0,1],
            "⠺": [1,1,1,0,1,0], "⠻": [1,1,1,0,1,1],
            "⠼": [1,1,1,1,0,0], "⠽": [1,1,1,1,0,1],
            "⠾": [1,1,1,1,1,0], "⠿": [1,1,1,1,1,1]
        ]
        
        // 입력받은 문자열의 각 글자를 순회하면서 점자로 변환하고,
        // 점자를 이진 숫자 배열로 변환하여 반환할 배열에 추가
        for i in 0..<str.count {
            // 입력받은 문자열에서 i번째 글자를 가져옴
            let char: Character = str.getChar(at: i)
            // i번째 글자에 해당하는 점자 문자를 딕셔너리에서 찾음 braille: "⠗"
            if let braille: Character = eng2Braille[char] {
                print(braille, terminator: " ")
                // 점자 문자에 해당하는 이진 숫자 배열을 반환할 배열에 추가
                returnValue.append(braille2IntArr[braille]!)
            }
        }
        // 변환된 이진 숫자 2DArr을 반환
        return returnValue
    }

    func isInside(_ location: CGPoint, geo: GeometryProxy) -> Bool {
        let frame = geo.frame(in: .local)
        return frame.contains(location)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// #################### extension ###################

extension String {
    subscript(_ index: Int) -> Character {
        if 0 <= index && index < self.count  {
            return self[self.index(self.startIndex, offsetBy: index)]
        }
       return Character(" ")
    }
    
    func getChar(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
