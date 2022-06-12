new class ColorCircle : Visual {
    new method __init__() {
        super().__init__(
            "Color Circle",
            (255, 255, 255),
            RefreshMode.NOREFRESH, True
        );
    }
    
    new method draw(array, indices, color) {
        new dynamic drawn = {}, pos, posEnd, angle, colorConstant = 1 / sortingVisualizer.arrayMax;

        for idx in indices {
            angle = Utils.translate(idx, 0, len(array), 
                sortingVisualizer.visualSizes.circleStart, 
                sortingVisualizer.visualSizes.circleEnd
            );

            if angle in drawn {
                continue;
            } else {
                drawn[angle] = None;
            }

            pos = Vector().fromAngle(angle);
            pos.magnitude(sortingVisualizer.visualSizes.circleRadius);
            pos = pos.getIntCoords();
            pos += sortingVisualizer.visualSizes.circleCenter;

            posEnd = Vector().fromAngle(angle + sortingVisualizer.visualSizes.angleStep);
            posEnd.magnitude(sortingVisualizer.visualSizes.circleRadius);
            posEnd = posEnd.getIntCoords();
            posEnd += sortingVisualizer.visualSizes.circleCenter;

            if color is None {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.polygon([
                    sortingVisualizer.visualSizes.circleCenter,
                    pos, posEnd
                    ], hsvToRgb(0));
                } else {
                    sortingVisualizer.graphics.polygon([
                    sortingVisualizer.visualSizes.circleCenter,
                    pos, posEnd
                    ], hsvToRgb(array[idx].value * colorConstant));
                }
            } else {
                sortingVisualizer.graphics.polygon([
                sortingVisualizer.visualSizes.circleCenter,
                pos, posEnd
                ], color);
            }
        }

        del drawn;
    }

    new method drawAux(array, indices, color) {
        sortingVisualizer.getAuxMax();
        new dynamic length        = len(array),
                    resolution    = sortingVisualizer.graphics.resolution.copy(), lineSize,
                    drawn          = {},
                    colorConstant = 1 / sortingVisualizer.auxMax, angleStep, circleCenter, circleRadius, 
                                                pos, posEnd, angle;

        if 360 == length {
            angleStep = 1;
        } else {
            angleStep = 360 / length;
        }

        angleStep = math.radians(angleStep);

        circleRadius = (resolution.y // 6) - 20;
            
        circleCenter = resolution.copy();
        circleCenter.y //= 4;
        circleCenter.y *= 3;
        circleCenter.x = resolution.x // 4;

        for idx in range(len(array)) {
            angle = Utils.translate(idx, 0, len(array), 
                sortingVisualizer.visualSizes.circleStart, 
                sortingVisualizer.visualSizes.circleEnd
            );

            if angle in drawn {
                continue;
            } else {
                drawn[angle] = None;
            }

            pos = Vector().fromAngle(angle);
            pos.magnitude(circleRadius);
            pos = pos.getIntCoords();
            pos += circleCenter;

            posEnd = Vector().fromAngle(angle + angleStep);
            posEnd.magnitude(circleRadius);
            posEnd = posEnd.getIntCoords();
            posEnd += circleCenter;

            if idx in indices {
                sortingVisualizer.graphics.polygon([
                circleCenter,
                pos, posEnd
                ], color);
            } else {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.polygon([
                    circleCenter,
                    pos, posEnd
                    ], hsvToRgb(0));
                } else {
                    sortingVisualizer.graphics.polygon([
                    circleCenter,
                    pos, posEnd
                    ], hsvToRgb(array[idx].value * colorConstant));
                }
            }
        }

        del drawn;
    }
}