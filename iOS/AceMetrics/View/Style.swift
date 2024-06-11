//
//  Style.swift
//
//  Created by Vijayakumar B on 27/03/21.
//

//  AceMetrics
//
// Copyright (C) 2024 Vectoral Innovations (OPC) Pvt. Ltd
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import SwiftUI

struct LexendFontModifier: ViewModifier {
    var style: UIFont.TextStyle = .body
    var weight: Font.Weight = .regular
    var size: CGFloat = 0.0

    func body(content: Content) -> some View {
        if NSLocale.current.languageCode == "ja" {
            content
                .font(Font.custom("NotoSansJP-Regular", size: size != 0.0 ? size : UIFont.preferredFont(forTextStyle: style).pointSize)
                .weight(weight))
        } else {
            content
                .font(Font.custom(style == .headline ? "Lexend-SemiBold" : "Lexend-Regular", size: size != 0.0 ? size : UIFont.preferredFont(forTextStyle: style).pointSize)
                .weight(weight))
        }
    }
}

extension View {
    func lexendFont(style: UIFont.TextStyle, weight: Font.Weight) -> some View {
        self.modifier(LexendFontModifier(style: style, weight: weight))
    }
    func lexendFont(weight: Font.Weight, size: CGFloat) -> some View {
        self.modifier(LexendFontModifier(weight: weight, size: size))
    }
    
    func titleFont() -> some View {
        var style: UIFont.TextStyle
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            style = .title3
        }
        else {
            style = .title1
        }
        
        return self.modifier(LexendFontModifier(style: style, weight: .medium))
    }
    
    func headlineFont() -> some View {
        var style: UIFont.TextStyle
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            style = .subheadline
        }
        else {
            style = .headline
        }
        
        return self.modifier(LexendFontModifier(style: style, weight: .medium))
    }
    
    func captionFont() -> some View {
        var style: UIFont.TextStyle
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            style = .caption2
        }
        else {
            style = .caption1
        }
        
        return self.modifier(LexendFontModifier(style: style, weight: .medium))
    }
    
    func smallPadding() -> some View {
        var length: CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone {
            length = 5
        }
        else {
            length = 10
        }
        
        return self.padding(length)
    }
}

struct ServeButtonStyle : ButtonStyle {
    private let glow: Color
    
    init (_ glow: Color = Color("rgbBall"))
    {
        self.glow = glow
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .shadow(color: self.glow, radius: configuration.isPressed ? 5 : 0)
            .shadow(color: self.glow, radius: configuration.isPressed ? 5 : 0)
            .shadow(color: self.glow, radius: configuration.isPressed ? 5 : 0)
    }
}
