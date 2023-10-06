new class RainbowBarGraph: LineVisual {
    new method __init__() {
        super().__init__(
            "Rainbow Bar Graph",
            (255, 255, 255)
        );
    }

    new method prepare() {
        super.prepare();

        this.colorConstant = 1.0 / sortingVisualizer.arrayMax;
    }

    new method onAuxOn(length) {
        super.onAuxOn(length);

        this.auxColorConstant = 1.0 / sortingVisualizer.auxMax;
    }

    new method draw(array, indices, color) {
        new dynamic drawn = {};
        
        for idx in range(len(array)) {
            new dynamic pos = sortingVisualizer.graphics.resolution.copy(), lineEnd;

            pos.x = Utils.translate(
                    idx, 0, len(array), 0, 
                    sortingVisualizer.graphics.resolution.x // this.lineSize
                ) * this.lineSize + (this.lineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            lineEnd = pos - Vector(0, int(array[idx].value * this.lineLengthConst));

            if idx in indices && color is not None {
                sortingVisualizer.graphics.line(pos, lineEnd, color, this.lineSize);
            } else {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.line(pos, lineEnd, (255, 0, 0), this.lineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, lineEnd, hsvToRgb(array[idx].value * colorConstant), this.lineSize);
                }   
            }
        }

        del drawn;
    }

    new method fastDraw(array, indices, color) {
        new dynamic drawn = {};

        for idx in indices {
            new dynamic pos = sortingVisualizer.graphics.resolution.copy(), lineEnd;

            pos.x = Utils.translate(
                idx, 0, len(array), 0, 
                sortingVisualizer.graphics.resolution.x // this.lineSize
            ) * this.lineSize + (this.lineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            lineEnd = pos - Vector(0, int(array[idx].value * this.lineLengthConst));

            if color is None {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.line(pos, lineEnd, (255, 0, 0), this.lineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, lineEnd, hsvToRgb(array[idx].value * colorConstant), this.lineSize);
                }   
            } else {
                sortingVisualizer.graphics.line(pos, lineEnd, color, this.lineSize);
            }

            sortingVisualizer.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), this.lineSize);
        }

        del drawn;
    }

    new method drawAux(array, indices, color) {
        new dynamic drawn = {};

        for idx in range(len(array)) {
            new dynamic pos = this.auxResolution.copy(), lineEnd;

            pos.x = Utils.translate(idx, 0, len(array), 0, this.auxResolution.x // this.auxLineSize) * this.auxLineSize + (this.auxLineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            lineEnd = pos - Vector(0, int(array[idx].value * this.lineLengthConst));
            
            if idx in indices {
                sortingVisualizer.graphics.line(pos, lineEnd, color, this.auxLineSize);
            } else {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.line(pos, lineEnd, (255, 0, 0), this.auxLineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, lineEnd, hsvToRgb(array[idx].value * this.colorConstant), this.auxLineSize);
                }   
            }

            sortingVisualizer.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), this.auxLineSize);
        }

        del drawn;
        
        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }
}