//
//  FonstBuilder.swift
//  GuitarTunerApp
//
//  Created by Negi on 04/08/26.
//

import SwiftUI

struct FontBuilder {

    let family: FontFamily
}


extension FontBuilder {

    func thin(_ size: AppFontSize) -> Font {
        makeFont(weight: .thin, size: size.rawValue)
    }

    func extraLight(_ size: AppFontSize) -> Font {
        makeFont(weight: .extraLight, size: size.rawValue)
    }

    func light(_ size: AppFontSize) -> Font {
        makeFont(weight: .light, size: size.rawValue)
    }

    func regular(_ size: AppFontSize) -> Font {
        makeFont(weight: .regular, size: size.rawValue)
    }

    func medium(_ size: AppFontSize) -> Font {
        makeFont(weight: .medium, size: size.rawValue)
    }

    func semiBold(_ size: AppFontSize) -> Font {
        makeFont(weight: .semiBold, size: size.rawValue)
    }

    func bold(_ size: AppFontSize) -> Font {
        makeFont(weight: .bold, size: size.rawValue)
    }

    func extraBold(_ size: AppFontSize) -> Font {
        makeFont(weight: .extraBold, size: size.rawValue)
    }

    func black(_ size: AppFontSize) -> Font {
        makeFont(weight: .black, size: size.rawValue)
    }
}


extension FontBuilder {

    func regular(_ size: CGFloat) -> Font {
        makeFont(weight: .regular, size: size)
    }

    func medium(_ size: CGFloat) -> Font {
        makeFont(weight: .medium, size: size)
    }

    func semiBold(_ size: CGFloat) -> Font {
        makeFont(weight: .semiBold, size: size)
    }

    func bold(_ size: CGFloat) -> Font {
        makeFont(weight: .bold, size: size)
    }
}



private extension FontBuilder {

    func makeFont(
        weight: FontWeight,
        size: CGFloat
    ) -> Font {

        let fontName = "\(family.rawValue)-\(weight.rawValue)"

        return .custom(
            fontName,
            size: size,
            relativeTo: .body
        )
    }
}
