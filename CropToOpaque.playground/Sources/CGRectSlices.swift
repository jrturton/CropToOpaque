import CoreGraphics

public class RectSliceGenerator: GeneratorType {
    var currentSlice: CGFloat = 0
    
    let rect: CGRect
    let startEdge: CGRectEdge
    
    init(rect: CGRect, startEdge: CGRectEdge) {
        self.rect = rect
        self.startEdge = startEdge
    }
    
    public func next() -> CGRect? {
        
        var next = rect
        
        switch startEdge {
        case .MaxXEdge, .MinXEdge:
            if currentSlice >= rect.width {
                return nil
            }
            next.size.width = 1.0
            next.origin.x = (startEdge == .MinXEdge ? currentSlice : rect.width - 1.0 - currentSlice)
        case .MaxYEdge, .MinYEdge:
            if currentSlice >= rect.height {
                return nil
            }
            next.size.height = 1.0
            next.origin.y = (startEdge == .MinYEdge ? currentSlice : rect.height - 1.0 - currentSlice)
        }
        currentSlice += 1.0
        return next
        
    }
}

public class RectSliceSequence: SequenceType {
    let rect: CGRect
    let startEdge: CGRectEdge
    
    init(rect: CGRect, startEdge: CGRectEdge) {
        self.rect = rect
        self.startEdge = startEdge
    }
    
    public func generate() -> RectSliceGenerator {
        return RectSliceGenerator(rect: rect, startEdge: startEdge)
    }
}

public extension CGRect {
    func slicesFromEdge(startEdge: CGRectEdge) -> RectSliceSequence {
        return RectSliceSequence(rect: self, startEdge: startEdge)
    }
}
