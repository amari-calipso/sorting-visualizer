new class WhiteBarGraph: LineVisual {
    new method __init__() {
        super().__init__(
            "Bar Graph",
            (255, 0, 0)
        );
    }

    new method draw(array, indices, color) {
        if color is None {
            color = (255, 255, 255);
        }

        new dynamic pos = sortingVisualizer.graphics.resolution.copy(),
                    end = pos.copy(), idx;
        pos.x = 0;
        end.x = 0;

        if len(array) > sortingVisualizer.graphics.resolution.x {
            new dynamic oldIdx = 0;
            unchecked: repeat sortingVisualizer.graphics.resolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));

                end.y = pos.y - int(array[idx].value * this.lineLengthConst);

                for i in indices {
                    if i in range(oldIdx, idx) {
                        sortingVisualizer.graphics.line(pos, end, color, 1);
                        break;
                    }
                } else {
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), 1);
                }

                pos.x++;
                end.x++;
                oldIdx = idx;
            }
        } else {
            for idx in range(len(array)) {
                pos.x = int(Utils.translate(
                    idx, 0, len(array), 
                    0, sortingVisualizer.graphics.resolution.x // this.lineSize
                )) * this.lineSize + (this.lineSize // 2);
                end.x = pos.x;

                end.y = pos.y - int(array[idx].value * this.lineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, color, this.lineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), this.lineSize);
                }
            }
        }
    }

    new method fastDraw(array, indices, color) {
        if color is None {
            color = (255, 255, 255);
        }

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
            
            sortingVisualizer.graphics.line(    pos,          lineEnd,     color, this.lineSize);
            sortingVisualizer.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), this.lineSize);
        }

        del drawn;
    }

    new method drawAux(array, indices, color) {
        new dynamic pos = this.auxResolution.copy(),
                    end = pos.copy(), idx;
        pos.x = 0;
        end.x = 0;

        if len(array) > this.auxResolution.x {
            new dynamic oldIdx = 0;
            unchecked: repeat this.auxResolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, this.auxResolution.x, 
                    0, len(array)
                ));

                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                for i in indices {
                    if i in range(oldIdx, idx) {
                        sortingVisualizer.graphics.line(pos, end, color, 1);
                        break;
                    }
                } else {
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), 1);
                }

                pos.x++;
                end.x++;
                oldIdx = idx;
            }
        } else {
            for idx in range(len(array)) {
                pos.x = int(Utils.translate(
                    idx, 0, len(array), 
                    0, sortingVisualizer.graphics.resolution.x // this.auxLineSize
                )) * this.auxLineSize + (this.auxLineSize // 2);
                end.x = pos.x;

                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, color, this.auxLineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), this.auxLineSize);
                }
            }
        }
        
        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }

    new method fastDrawAux(array, indices, color) {
        new dynamic pos = this.auxResolution.copy(),
                    end = pos.copy(), idx;
        pos.x = 0;
        end.x = 0;

        if len(array) > this.auxResolution.x {
            unchecked: repeat this.auxResolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, this.auxResolution.x, 
                    0, len(array)
                ));

                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, color, 1);
                } else {
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), 1);
                }
                    
                pos.x++;
                end.x++;
            }
        } else {
            for idx in range(len(array)) {
                pos.x = int(Utils.translate(
                    idx, 0, len(array), 
                    0, sortingVisualizer.graphics.resolution.x // this.auxLineSize
                )) * this.auxLineSize + (this.auxLineSize // 2);
                end.x = pos.x;
                
                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, color, this.auxLineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), this.auxLineSize);
                }
            }
        }

        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }
}