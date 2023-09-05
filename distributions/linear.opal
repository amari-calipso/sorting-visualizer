@Distribution("Linear");
new function linear(array, length) {
    while True {
        new int uniqueAmount;
        uniqueAmount = length // sortingVisualizer.getUserInput(
            "Insert amount of unique items (default = " + str(length) + ")", 
            str(length // 2)
        );

        if uniqueAmount == 0 {
            sortingVisualizer.userWarn("Invalid unique amount. Please retry.");
            continue;
        }

        break;
    }

    for i = 1; i + uniqueAmount < length + 1; i += uniqueAmount {
        for j in range(uniqueAmount) {
            array[i - 1 + j] = Value(i // uniqueAmount);
        }
    }

    new int val = i // uniqueAmount;
    i -= 1;
    for ; i < length; i++ {
        array[i] = Value(val);
    }
}