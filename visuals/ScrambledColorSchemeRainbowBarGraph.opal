new class ScrambledRainbowBarGraph : Visual {
    new method __init__() {
        super().__init__(
            "Scrambled Scheme Rainbow Bar Graph",
            (255, 255, 255)
        );
    }

    new method draw(array, indices, color) {
        new dynamic colorConstant = 1 / len(array), drawn = {};

        for idx in indices {
            new dynamic pos = sortingVisualizer.graphics.resolution.copy(), lineEnd;

            pos.x = Utils.translate(idx, 0, len(array), 0, 
                sortingVisualizer.graphics.resolution.x // 
                sortingVisualizer.visualSizes.lineSize
            ) * sortingVisualizer.visualSizes.lineSize + 
            (sortingVisualizer.visualSizes.lineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            lineEnd = pos - Vector(0, int(array[idx].value * sortingVisualizer.visualSizes.lineLengthConst));

            if color is None {
                sortingVisualizer.graphics.line(pos, lineEnd, hsvToRgb(array[idx].stabIdx * colorConstant), sortingVisualizer.visualSizes.lineSize);
            } else {
                sortingVisualizer.graphics.line(pos, lineEnd, color, sortingVisualizer.visualSizes.lineSize);
            }
            sortingVisualizer.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), sortingVisualizer.visualSizes.lineSize);
        }

        del drawn;
    }

    new method drawAux(array, indices, color) {
        sortingVisualizer.getAuxMax();
        new dynamic length        = len(array),
                    resolution    = sortingVisualizer.graphics.resolution.copy(), lineSize,
                    drawn          = {},
                    colorConstant = 1 / len(array);

        resolution.y //= 4;

        new dynamic lineLengthConst = resolution.y / sortingVisualizer.auxMax;

        if resolution.x >= length {
            if resolution.x == length {
                lineSize = 1;
            } else {
                lineSize = math.ceil(resolution.x / length);
            }
        } else {
            lineSize = 1;
        }

        for idx in range(len(array)) {
            new dynamic pos = resolution.copy(), lineEnd;

            pos.x = Utils.translate(idx, 0, len(array), 0, resolution.x // lineSize) * lineSize + (lineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            lineEnd = pos - Vector(0, int(array[idx].value * lineLengthConst));
            
            if idx in indices {
                sortingVisualizer.graphics.line(pos, lineEnd,                                        color, lineSize);
            } else {
                sortingVisualizer.graphics.line(pos, lineEnd, hsvToRgb(array[idx].stabIdx * colorConstant), lineSize);
            }
            sortingVisualizer.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), lineSize);
        }

        del drawn;

        sortingVisualizer.graphics.line(Vector(0, resolution.y), resolution, (0, 0, 255), 2);
    }
}