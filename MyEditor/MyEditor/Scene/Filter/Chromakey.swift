//
//  Chromakey.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import CoreImage

class ChromaKeyFilter: CIFilter {
    var kernel: CIKernel?
    var inputImage: CIImage?
    var activeColor = CIColor(red: 0, green: 1.0, blue: 0)
    var threshhold = 0.7
    
    override init() {
        super.init()
        kernel = createKernel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        kernel = createKernel()
    }
    
    override var outputImage : CIImage? {
        if let inputImage = inputImage, let kernel = kernel {
            let dod = inputImage.extent
            let args = [inputImage as AnyObject, activeColor as AnyObject, threshhold as AnyObject]
            return kernel.apply(extent: dod, roiCallback: { (a, b) -> CGRect in
                print("____a=\(a)_____b=\(b)")
                return b
            }, arguments: args)
        }
        return nil
    }
    
    private func createKernel() -> CIColorKernel {
        let kernelString =
            "kernel vec4 chromaKey( __sample s, __color c, float threshold ) { \n" +
            "  vec4 diff = s.rgba - c;\n" +
            "  float distance = length( diff );\n" +
            "  float alpha = compare( distance - threshold, 0.0, 1.0 );\n" +
            "  return vec4( s.rgb, alpha ); \n" +
            "}"
        guard let kernel = CIColorKernel(source: kernelString) else {
            fatalError()
        }
        return kernel
    }
}
