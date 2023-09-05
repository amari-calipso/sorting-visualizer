# Copyright (c) 2020 thatsOven
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# Helium Sort
# 
# A block merge sorting algorithm inspired by GrailSort and focused on adaptivity.
# 
# Time complexity:
#  - Best case: O(n)
#  - Average case: O(n log n)
#  - Worst case: O(n log n)
# Space complexity is variable.
# 
# The algorithm extends the concept of adaptivity to memory,
# by using different strategies based on the amount
# of memory given to it. 
# 
# Major strategies are:
# "Uranium": merge sort, requires n / 2 memory.
#            The code refers to it as "Strategy 1".
# 
# "Hydrogen": block merge sort, requires "x" memory with sqrt(n) + n / sqrt(n) <= x < n / 2.
#             To run optimally, Hydrogen mode requires exactly sqrt(n) + 2n / sqrt(n) memory.
#             Hydrogen mode might switch to Helium mode if amount of given memory < sqrt(n) + 2n / sqrt(n), 
#             and the array contains less than n / sqrt(n) distinct values.
#             Hydrogen mode uses two strategies, referred as "2A" and "2B".
# 
# "Helium": block merge sort, requires "x" memory with 0 <= x < sqrt(n) + n / sqrt(n).
#           Helium mode uses five strategies, referred to as: "3A", "3B", "3C", "4A", 
#           and "4B". Optimal amounts of memory are:
#              - sqrt(n): will use strategy 3B or 4A;
#              - 0: will use strategy 3C or 4B.
#           Strategy 3A is only used when Hydrogen mode switches.
# 
# When a very low amount of distinct values is found or the array size is less or equal than 256, 
# the sort uses an adaptive in-place merge sort referred to as "Strategy 5".
# 
# Special thanks to the members of The Holy Grail Sort Project, for the creation of Rewritten GrailSort,
# which has been a great reference during the development of this algorithm,
# and thanks to aphitorite, a great sorting mind which inspired the creation of this algorithm,
# alongside being very helpful for me to understand some of the workings of block merge sorting algorithms,
# and for part of the code used in this algorithm itself: "smarter block selection", 
# the algorithm used in the "blockSelectInPlace" and "blockSelectOOP" routines, and the 
# code used in the "mergeBlocks" routine.

use reverse, arrayCopy, blockSwap, backwardBlockSwap, 
    compareValues, compareIntToValue, insertToLeft,
    heliumRotate, checkMergeBounds, lrBinarySearch, binaryInsertionSort;

new class HeliumSort {
    new int RUN_SIZE           = 32,
            SMALL_SORT         = 256,
            MIN_SORTED_UNIQUE  = 8,
            MAX_STRAT5_UNIQUE  = 8,
            MIN_REV_RUN_SIZE   = 8,
            SMALL_MERGE        = 16;

    new method __init__() {
        this.buffer  = None;
        this.indices = None;
        this.keys    = None;
    }

    new method reverseRuns(array, a, b) {
        new int l = a;
        while l < b {
            for i = l; i < b - 1; i++ {
                if array[i] <= array[i + 1] {
                    break;
                }
            }

            if i - l >= HeliumSort.MIN_REV_RUN_SIZE {
                reverse(array, l, i);
            }

            l = i + 1;
        }
    }

    new method checkSortedIdx(array, a, b) {
        this.reverseRuns(array, a, b);

        for ; a < b - 1; a++ {
            if array[a] > array[a + 1] {
                return a;
            }
        }

        return b;
    }

    new method findKeysUnsorted(array, a, p, b, q, to) {
        new int n = p - a;

        p = a;
        for i = p + n; i < b && n < q; i++ {
            new int l = lrBinarySearch(array, p, p + n, array[i], True);
            if i == l || array[i] != array[l] {
                heliumRotate(array, p, p + n, i);
                new int add = i - p - n;
                l += add;
                p += add;

                insertToLeft(array, p + n, l);
                n++;
            }
        }

        heliumRotate(array, to, p, p + n);
        return n;
    }

    new method findKeysSorted(array, a, b, q) {
        new int n = 1,
                p = a;
        
        for i = a + 1; i < b && n < q; i++ {
            if array[i] > array[i - 1] {
                heliumRotate(array, p, p + n, i);
                p = i + n;
                n++;
            }
        }

        if n == q {
            heliumRotate(array, a, p, p + n);
        } else {
            heliumRotate(array, p, p + n, b);
        }

        return n;
    }

    new method findKeys(array, a, b, q) {
        new int p = this.checkSortedIdx(array, a, b);
        if p == b {
            return None;
        }

        if p - a < HeliumSort.MIN_SORTED_UNIQUE {
            return this.findKeysUnsorted(array, a, a, b, q, a);
        } else {
            new int n = this.findKeysSorted(array, a, p, q);
            if n == q {
                return n;
            }

            return this.findKeysUnsorted(array, p - n, p, b, q, a);
        }
    }

    new method sortRuns(array, a, b) {
        new dynamic speed = sortingVisualizer.speed;
        sortingVisualizer.setSpeed(max(int(10 * (len(array) / 2048)), speed * 2));

        for i = a; i < b - HeliumSort.RUN_SIZE; i += HeliumSort.RUN_SIZE {
            binaryInsertionSort(array, i, i + HeliumSort.RUN_SIZE);
        }

        if i < b {
            binaryInsertionSort(array, i, b);
        }

        sortingVisualizer.setSpeed(speed);
    }

    new method reduceMergeBounds(array, a, m, b) {
        return (
            lrBinarySearch(array, a, m - 1, array[m    ], False),
            lrBinarySearch(array, m, b    , array[m - 1], True)
        );
    }

    new method mergeInPlaceFW(array, a, m, b, left = True) {
        new int s = a,
                l = m;

        while s < l && l < b {
            new int cmp = compareValues(array[s], array[l]);
            if cmp > 0 if left else cmp >= 0 {
                new int p = lrBinarySearch(array, l, b, array[s], left);
                heliumRotate(array, s, l, p);
                s += p - l;
                l = p;
            } else {
                s++;
            }
        }
    }

    new method mergeInPlaceBW(array, a, m, b, left = True) {
        new int s = b - 1,
                l = m - 1;

        while s > l && l >= a {
            new int cmp = compareValues(array[l], array[s]);
            if cmp > 0 if left else cmp >= 0 {
                new int p = lrBinarySearch(array, a, l, array[s], !left);
                heliumRotate(array, p, l + 1, s + 1);
                s -= l + 1 - p;
                l = p - 1;
            } else {
                s--;
            }
        }
    }

    new method mergeInPlace(array, a, m, b, left = True, check = True) {
        if check {
            if checkMergeBounds(array, a, m, b) {
                return;
            }

            a, b = this.reduceMergeBounds(array, a, m, b);
        }

        if m - a > b - m {
            this.mergeInPlaceBW(array, a, m, b, left);
        } else {
            this.mergeInPlaceFW(array, a, m, b, left);
        }
    }

    new classmethod mergeWithBufferFW(array, a, m, b, buf, left = True) {
        new int ll = m - a;
        blockSwap(array, a, buf, ll);

        new int l = buf,
                r = m,
                o = a,
                e = buf + ll;

        for ; l < e && r < b; o++ {
            new int cmp = compareValues(array[l], array[r]);
            if cmp <= 0 if left else cmp < 0 {
                array[o].swap(array[l]);
                l++;
            } else {
                array[o].swap(array[r]);
                r++;
            }
        }

        for ; l < e; o++, l++ {
            array[o].swap(array[l]);
        }
    }

    new classmethod mergeWithBufferBW(array, a, m, b, buf, left = True) {
        new int rl = b - m;
        backwardBlockSwap(array, m, buf, rl);

        new int l = m - 1,
                r = buf + rl - 1,
                o = b - 1;

        for ; l >= a && r >= buf; o-- {
            new int cmp = compareValues(array[r], array[l]);
            if cmp >= 0 if left else cmp > 0 {
                array[o].swap(array[r]);
                r--;
            } else {
                array[o].swap(array[l]);
                l--;
            }
        }

        for ; r >= buf; o--, r-- {
            array[o].swap(array[r]);
        }
    }

    new method mergeWithBuffer(array, a, m, b, buf, left = True) {
        if checkMergeBounds(array, a, m, b) {
            return;
        }

        a, b = this.reduceMergeBounds(array, a, m, b);

        new int ll = m - a,
                rl = b - m;

        if ll > rl {
            if rl <= HeliumSort.SMALL_MERGE {
                this.mergeInPlaceBW(array, a, m, b, left);
            } else {
                this.mergeWithBufferBW(array, a, m, b, buf, left);
            }
        } else {
            if ll <= HeliumSort.SMALL_MERGE {
                this.mergeInPlaceFW(array, a, m, b, left);
            } else {
                this.mergeWithBufferFW(array, a, m, b, buf, left);
            }
        }
    }

    new method mergeOOPFW(array, a, m, b, left = True) {
        new int ll = m - a;
        arrayCopy(array, a, this.buffer, 0, ll);

        new int l = 0,
                r = m,
                o = a,
                e = ll;

        for ; l < e && r < b; o++ {
            new int cmp = compareValues(this.buffer[l], array[r]);
            if cmp <= 0 if left else cmp < 0 {
                array[o].write(this.buffer[l]);
                l++;
            } else {
                array[o].write(array[r]);
                r++;
            }
        }

        for ; l < e; o++, l++ {
            array[o].write(this.buffer[l]);
        }
    }

    new method mergeOOPBW(array, a, m, b, left = True) {
        new int rl = b - m;
        arrayCopy(array, m, this.buffer, 0, rl);

        new int l = m  - 1,
                r = rl - 1,
                o = b  - 1;

        for ; l >= a && r >= 0; o-- {
            new int cmp = compareValues(this.buffer[r], array[l]);
            if cmp >= 0 if left else cmp > 0 {
                array[o].write(this.buffer[r]);
                r--;
            } else {
                array[o].write(array[l]);
                l--;
            }
        }

        for ; r >= 0; o--, r-- {
            array[o].write(this.buffer[r]);
        }
    }

    new method mergeOOP(array, a, m, b, left = True) {
        if checkMergeBounds(array, a, m, b) {
            return;
        }

        a, b = this.reduceMergeBounds(array, a, m, b);

        new int ll = m - a,
                rl = b - m;

        if ll > rl {
            if rl <= HeliumSort.SMALL_MERGE {
                this.mergeInPlaceBW(array, a, m, b, left);
            } else {
                this.mergeOOPBW(array, a, m, b, left);
            }
        } else {
            if ll <= HeliumSort.SMALL_MERGE {
                this.mergeInPlaceFW(array, a, m, b, left);
            } else {
                this.mergeOOPFW(array, a, m, b, left);
            }
        }
    }

    new method optiSmartMerge(array, a, m, b, buf, left) {
        new int ll = m - a,
                rl = b - m;

        if ll > rl {
            if rl <= HeliumSort.SMALL_MERGE {
                this.mergeInPlaceBW(array, a, m, b, left);
                return True;
            }

            if this.buffer is not None && rl < len(this.buffer) {
                this.mergeOOPBW(array, a, m, b, left);
            } elif rl <= this.bufLen {
                this.mergeWithBufferBW(array, a, m, b, buf, left);
            } else {
                return False;
            }
        } else {
            if ll <= HeliumSort.SMALL_MERGE {
                this.mergeInPlaceFW(array, a, m, b, left);
                return True;
            }

            if this.buffer is not None && ll <= len(this.buffer) {
                this.mergeOOPFW(array, a, m, b, left);
            } elif ll <= this.bufLen {
                this.mergeWithBufferFW(array, a, m, b, buf, left);
            } else {
                return False;
            }
        }

        return True;
    }

    new method optiMerge(array, a, m, b, buf) {
        a, b = this.reduceMergeBounds(array, a, m, b);
        return this.optiSmartMerge(array, a, m, b, buf, True);
    }

    new method keyBlockSwapCycle(array, a, kA, kB, blockLen) {
        blockSwap(array, a + kA * blockLen, a + kB * blockLen, blockLen);
        this.indices[kA].swap(this.indices[kB]);
    }

    new method keyBlockSwapCycleInPlace(array, a, stKey, kA, kB, blockLen) {
        this.keyBlockSwapCycle(array, a, kA, kB, blockLen);
        array[kA + stKey].swap(array[kB + stKey]);
    }

    new method keyBlockSwapCycleOOP(array, a, kA, kB, blockLen) {
        this.keyBlockSwapCycle(array, a, kA, kB, blockLen);
        this.keys[kA].swap(this.keys[kB]);
    }

    new method getBlocksIndices(array, a, leftBlocks, rightBlocks, blockLen) {
        new int l = 0,
                m = leftBlocks,
                r = m,
                b = m + rightBlocks,
                o = 0;

        for ; l < m && r < b; o++ {
            if array[a + (l + 1) * blockLen - 1] <= 
               array[a + (r + 1) * blockLen - 1] 
            {
                this.indices[l].write(o);
                l++;
            } else {
                this.indices[r].write(o);
                r++;
            }
        }

        for ; l < m; o++, l++ {
            this.indices[l].write(o);
        }

        for ; r < b; o++, r++ {
            this.indices[r].write(o);
        }
    }

    new method blockCycleInPlace(array, stKey, a, leftBlocks, rightBlocks, blockLen) {
        new int total = leftBlocks + rightBlocks;
        for i = 0; i < total; i++ {
            for cmpCnt = 0; cmpCnt < total && this.indices[i] != i; cmpCnt++ {
                this.keyBlockSwapCycleInPlace(array, a, stKey, i, this.indices[i].readInt(), blockLen);
            }

            if cmpCnt >= total - 1 {
                break;
            }
        }
    }

    new method blockCycleOOP(array, a, leftBlocks, rightBlocks, blockLen) {
        new int total = leftBlocks + rightBlocks;
        for i = 0; i < total; i++ {
            for cmpCnt = 0; cmpCnt < total && this.indices[i] != i; cmpCnt++ {
                this.keyBlockSwapCycleOOP(array, a, i, this.indices[i].readInt(), blockLen);
            }

            if cmpCnt >= total - 1 {
                break;
            }
        }
    }

    new method blockSelectInPlace(array, stKey, a, leftBlocks, rightBlocks, blockLen) {
        new int i1 = stKey,
                tm = stKey + leftBlocks,
                j1 = tm,
                k  = stKey,
                tb = tm + rightBlocks;

        while k < j1 && j1 < tb {
            if array[a + (i1 - stKey + 1) * blockLen - 1] <= 
               array[a + (j1 - stKey + 1) * blockLen - 1] 
            {
                if i1 > k {
                    blockSwap(
                        array, 
                        a + (k - stKey) * blockLen, 
                        a + (i1 - stKey) * blockLen, 
                        blockLen
                    );
                }

                array[k].swap(array[i1]);
                k++;

                i1 = k;
                for i = max(k + 1, tm); i < j1; i++ {
                    if array[i] < array[i1] {
                        i1 = i;
                    }
                }
            } else {
                blockSwap(
                    array, 
                    a + (k - stKey) * blockLen, 
                    a + (j1 - stKey) * blockLen, 
                    blockLen
                );

                array[k].swap(array[j1]);
                j1++;

                if i1 == k {
                    i1 = j1 - 1;
                }
                k++;
            }
        }

        while k < j1 - 1 {
            if i1 > k {
                blockSwap(
                    array, 
                    a + (k - stKey) * blockLen, 
                    a + (i1 - stKey) * blockLen, 
                    blockLen
                );
            }

            array[k].swap(array[i1]);
            k++;

            i1 = k;
            for i = k + 1; i < j1; i++ {
                if array[i] < array[i1] {
                    i1 = i;
                }
            }
        }
    }

    new method blockSelectOOP(array, a, leftBlocks, rightBlocks, blockLen) {
        new int i1 = 0,
                tm = leftBlocks,
                j1 = tm,
                k  = 0,
                tb = tm + rightBlocks;

        while k < j1 && j1 < tb {
            if array[a + (i1 + 1) * blockLen - 1] <= 
               array[a + (j1 + 1) * blockLen - 1] 
            {
                if i1 > k {
                    blockSwap(
                        array, 
                        a + k * blockLen, 
                        a + i1 * blockLen, 
                        blockLen
                    );
                }

                this.keys[k].swap(this.keys[i1]);
                k++;

                i1 = k;
                for i = max(k + 1, tm); i < j1; i++ {
                    if this.keys[i] < this.keys[i1] {
                        i1 = i;
                    }
                }
            } else {
                blockSwap(
                    array, 
                    a + k * blockLen, 
                    a + j1 * blockLen, 
                    blockLen
                );

                this.keys[k].swap(this.keys[j1]);
                j1++;

                if i1 == k {
                    i1 = j1 - 1;
                }
                k++;
            }
        }

        while k < j1 - 1 {
            if i1 > k {
                blockSwap(
                    array, 
                    a + k * blockLen, 
                    a + i1 * blockLen, 
                    blockLen
                );
            }

            this.keys[k].swap(this.keys[i1]);
            k++;

            i1 = k;
            for i = k + 1; i < j1; i++ {
                if this.keys[i] < this.keys[i1] {
                    i1 = i;
                }
            }
        }
    }

    new method smartMerge(array, a, m, b, left) {
        if this.optiSmartMerge(array, a, m, b, this.bufPos, left) {
            return;
        }

        this.mergeInPlace(array, a, m, b, left, False);
    }

    new method mergeBlocks(array, a, midKey, blockQty, blockLen, lastLen, stKey, keys) {
        new int f = a;
        new bool left = keys[stKey] < midKey;
        
        for i = 1; i < blockQty; i++ {
            if left ^ (keys[stKey + i] < midKey) {
                new int next    = a + i * blockLen,
                        nextEnd = lrBinarySearch(array, next, next + blockLen, array[next - 1], left);

                this.smartMerge(array, f, next, nextEnd, left);
                f = nextEnd;
                !left;
            }
        }

        if left && lastLen != 0 {
            new int lastFrag = a + blockQty * this.blockLen;
            this.smartMerge(array, f, lastFrag, lastFrag + lastLen, left);
        }
    }

    new method prepareOOPKeys(blockQty) {
        for i = 0; i < blockQty; i++ {
            this.keys[i].write(i);
        }
    }

    new method hydrogenCombine(array, a, m, b) {
        if checkMergeBounds(array, a, m, b) {
            return;
        }

        if this.optiMerge(array, a, m, b, this.bufPos) {
            return;
        }

        new int leftBlocks  = (m - a) // this.blockLen,
                rightBlocks = (b - m) // this.blockLen,
                blockQty    = leftBlocks + rightBlocks,
                frag        = (b - a) - blockQty * this.blockLen;

        this.getBlocksIndices(array, a, leftBlocks, rightBlocks, this.blockLen);

        if this.keys is None {
            binaryInsertionSort(array, this.keyPos, this.keyPos + blockQty + 1);

            new int midKey = array[this.keyPos + leftBlocks].readInt();

            this.blockCycleInPlace(
                array, this.keyPos, a,
                leftBlocks, rightBlocks, this.blockLen
            );

            this.mergeBlocks(array, a, midKey, blockQty, this.blockLen, frag, this.keyPos, array);
        } else {
            this.prepareOOPKeys(blockQty);

            this.blockCycleOOP(
                array, a, leftBlocks,
                rightBlocks, this.blockLen
            );

            this.mergeBlocks(array, a, leftBlocks, blockQty, this.blockLen, frag, 0, this.keys);
        }
    }

    new method heliumCombine(array, a, m, b) {
        if checkMergeBounds(array, a, m, b) {
            return;
        }

        if this.optiMerge(array, a, m, b, this.bufPos) {
            return;
        }

        new int leftBlocks  = (m - a) // this.blockLen,
                rightBlocks = (b - m) // this.blockLen,
                blockQty    = leftBlocks + rightBlocks,
                frag        = (b - a) - blockQty * this.blockLen;

        if this.keys is None {
            binaryInsertionSort(array, this.keyPos, this.keyPos + blockQty + 1);

            new int midKey = array[this.keyPos + leftBlocks].readInt();

            this.blockSelectInPlace(
                array, this.keyPos, a,
                leftBlocks, rightBlocks, this.blockLen
            );

            this.mergeBlocks(array, a, midKey, blockQty, this.blockLen, frag, this.keyPos, array);
        } else {
            this.prepareOOPKeys(blockQty);

            this.blockSelectOOP(
                array, a, leftBlocks,
                rightBlocks, this.blockLen
            );

            this.mergeBlocks(array, a, leftBlocks, blockQty, this.blockLen, frag, 0, this.keys);
        }
    }

    new method uraniumLoop(array, a, b) {
        new int r = HeliumSort.RUN_SIZE;
        while r < b - a {
            new int twoR = r * 2;
            for i = a; i < b - twoR; i += twoR {
                this.mergeOOP(array, i, i + r, i + twoR);
            }

            if i + r < b {
                this.mergeOOP(array, i, i + r, b);
            }

            r = twoR;
        }
    }

    new method hydrogenLoop(array, a, b) {
        new int r = HeliumSort.RUN_SIZE;
        while r < len(this.buffer) {
            new int twoR = r * 2;
            for i = a; i < b - twoR; i += twoR {
                this.mergeOOP(array, i, i + r, i + twoR);
            }

            if i + r < b {
                this.mergeOOP(array, i, i + r, b);
            }

            r = twoR;
        }

        while r < b - a {
            new int twoR = r * 2;
            for i = a; i < b - twoR; i += twoR {
                this.hydrogenCombine(array, i, i + r, i + twoR);
            }

            if i + r < b {
                this.hydrogenCombine(array, i, i + r, b);
            }

            r = twoR;
        }

        if this.keyLen != 0 {
            new int s = this.keyPos,
                    e = s + this.keyLen;

            binaryInsertionSort(array, s, e);

            if this.keyLen > HeliumSort.SMALL_MERGE {
                this.mergeOOP(array, s, e, b);
            } else {
                this.mergeInPlace(array, s, e, b);
            }
        }
    }

    new method heliumLoop(array, a, b) {
        new int r = HeliumSort.RUN_SIZE;
        if this.buffer is not None {
            while r < len(this.buffer) {
                new int twoR = r * 2;
                for i = a; i < b - twoR; i += twoR {
                    this.mergeOOP(array, i, i + r, i + twoR);
                }

                if i + r < b {
                    this.mergeOOP(array, i, i + r, b);
                }

                r = twoR;
            }
        }

        while r < this.bufLen {
            new int twoR = r * 2;
            for i = a; i < b - twoR; i += twoR {
                this.mergeWithBuffer(array, i, i + r, i + twoR, this.bufPos);
            }

            if i + r < b {
                this.mergeWithBuffer(array, i, i + r, b, this.bufPos);
            }

            r = twoR;
        }

        new bool strat4       = this.blockLen == 0,
                 internalKeys = this.keys is None;

        while r < b - a {
            new int twoR = r * 2;

            if strat4 {
                new int kLen = this.bufLen if this.keyLen == 0 else this.keyLen,
                        kBuf = (kLen + (kLen & 1)) // 2,
                        bLen = 1, target;

                if kBuf >= twoR // kBuf {
                    if internalKeys {
                        this.bufLen = kBuf;
                        this.bufPOs = this.keyPos + this.keyLen - kBuf;
                    }

                    target = kBuf;
                } else {
                    if internalKeys {
                        this.bufLen = 0;
                    }

                    target = twoR // kLen;
                }

                for ; bLen <= target; bLen *= 2 {}
                this.blockLen = bLen;
            }

            for i = a; i < b - twoR; i += twoR {
                this.heliumCombine(array, i, i + r, i + twoR);
            }

            if i + r < b {
                if strat4 && b - i - r <= this.keyLen {
                    this.bufPos = this.keyPos;
                    this.bufLen = this.keyLen;
                }

                this.heliumCombine(array, i, i + r, b);
            }

            r = twoR;
        }

        if this.keyLen != 0 || this.bufLen != 0 {
            new int s = this.bufPos if this.keyPos == -1 else this.keyPos,
                    l = this.keyLen + this.bufLen,
                    e = s + l;

            binaryInsertionSort(array, s, e);

            if this.buffer is not None && l <= len(this.buffer) && l > SMALL_MERGE {
                this.mergeOOP(array, s, e, b);
            } else {
                this.mergeInPlace(array, s, e, b);
            }
        }
    }

    new method inPlaceMergeSort(array, a, b, check = True) {
        if check && this.checkSortedIdx(array, a, b) == b {
            return;
        }

        this.sortRuns(array, a, b);

        new int r = HeliumSort.RUN_SIZE;
        while r < b - a {
            new int twoR = r * 2;
            for i = a; i < b - twoR; i += twoR {
                this.mergeInPlace(array, i, i + r, i + twoR);
            }

            if i + r < b {
                this.mergeInPlace(array, i, i + r, b);
            }

            r = twoR;
        }
    }

    new method __bufIdxKeysAdapt(array) {
        return array + this.indices + this.keys;
    }

    new method __bufIdxAdapt(array) {
        return array + this.indices;
    }

    new method __bufKeysAdapt(array) {
        return array + this.keys;
    }

    new method sort(array, a, b, mem) {
        new int n = b - a;
        if n <= HeliumSort.SMALL_SORT {
            this.inPlaceMergeSort(array, a, b);
            return;
        }

        if mem >= n // 2 || mem == -1 {
            if mem == -1 {
                mem = n // 2;
            }

            if this.checkSortedIdx(array, a, b) == b {
                return;
            }
            
            this.sortRuns(array, a, b);

            this.buffer = sortingVisualizer.createValueArray(mem);
            sortingVisualizer.setAux(this.buffer);

            this.uraniumLoop(array, a, b);

            return;
        }

        for sqrtn = 1; sqrtn * sqrtn < n; sqrtn *= 2 {}
        new int keySize = n // sqrtn;

        if mem >= sqrtn + 2 * keySize || mem == -2 {
            if mem == -2 {
                mem = sqrtn + 2 * keySize;
            }

            if this.checkSortedIdx(array, a, b) == b {
                return;
            }
            
            this.sortRuns(array, a, b);

            this.indices = sortingVisualizer.createValueArray(keySize);
            this.keys    = sortingVisualizer.createValueArray(keySize);
            this.buffer  = sortingVisualizer.createValueArray(mem - 2 * keySize);
            sortingVisualizer.setAux(this.buffer);
            sortingVisualizer.setAdaptAux(this.__bufIdxKeysAdapt);

            this.blockLen = sqrtn;
            this.bufLen = 0;
            this.bufPos = 0;
            this.keyLen = 0;
            this.keyPos = 0;

            this.hydrogenLoop(array, a, b);

            return;
        }

        if mem >= sqrtn + keySize || mem == -3 {
            if mem == -3 {
                mem = sqrtn + keySize;
            }

            new dynamic keysFound = this.findKeys(array, a, b, keySize);
            if keysFound is None {
                return;
            }

            this.blockLen = sqrtn;

            if keysFound == keySize {
                this.sortRuns(array, a + keysFound, b);

                this.indices = sortingVisualizer.createValueArray(keySize);
                this.buffer  = sortingVisualizer.createValueArray(mem - keySize);
                sortingVisualizer.setAux(this.buffer);
                sortingVisualizer.setAdaptAux(this.__bufIdxAdapt);

                this.keyLen = keysFound;
                this.keyPos = a;
                this.bufLen = 0;
                this.bufPos = -1;

                this.hydrogenLoop(array, a + keysFound, b);
            } else {
                this.sortRuns(array, a, b);

                this.keys   = sortingVisualizer.createValueArray(keySize);
                this.buffer = sortingVisualizer.createValueArray(mem - keySize);
                sortingVisualizer.setAux(this.buffer);
                sortingVisualizer.setAdaptAux(this.__bufKeysAdapt);

                this.bufLen = 0;
                this.bufPos = -1;
                this.keyLen = 0;
                this.keyPos = -1;

                this.heliumLoop(array, a, b);
            }

            return;
        }

        if mem >= sqrtn || mem == -4 {
            if mem == -4 {
                mem = sqrtn;
            }

            new dynamic keysFound = this.findKeys(array, a, b, keySize);
            if keysFound is None {
                return;
            }

            if keysFound <= HeliumSort.MAX_STRAT5_UNIQUE {
                this.inPlaceMergeSort(array, a, b, False);
                return;
            }

            this.sortRuns(array, a + keysFound, b);

            this.buffer = sortingVisualizer.createValueArray(mem);
            sortingVisualizer.setAux(this.buffer);

            this.bufLen = 0;
            this.bufPos = -1;
            this.keyLen = keysFound;
            this.keyPos = a;

            if keysFound == keySize {
                this.blockLen = sqrtn;
            } else {
                this.blockLen = 0;
            }

            this.heliumLoop(array, a + keysFound, b);

            return;
        }

        new int ideal = sqrtn + keySize;
        new dynamic keysFound = this.findKeys(array, a, b, ideal);
        if keysFound is None {
            return;
        }

        if keysFound <= HeliumSort.MAX_STRAT5_UNIQUE {
            this.inPlaceMergeSort(array, a, b, False);
            return;
        }

        this.sortRuns(array, a + keysFound, b);

        if mem > 0 {
            this.buffer = sortingVisualizer.createValueArray(mem);
            sortingVisualizer.setAux(this.buffer);
        }

        if keysFound == ideal {
            this.blockLen = sqrtn;
            this.bufLen   = sqrtn;
            this.bufPos   = a + keySize;
            this.keyLen   = keySize;
            this.keyPos   = a;
        } else {
            this.blockLen = 0;
            this.bufLen   = keysFound;
            this.bufPos   = a;
            this.keyLen   = keysFound;
            this.keyPos   = a;
        }

        this.heliumLoop(array, a + keysFound, b);
    }
}

@Sort(
    "Block Merge Sorts",
    "Helium Sort",
    "Helium Sort"
);
new function heliumGenSortRun(array) {
    new int mem = sortingVisualizer.getUserInput("Insert memory size (or -4 .. -1 for default modes)", "0");
    HeliumSort().sort(array, 0, len(array), mem);
}

@Sort(
    "Merge Sorts",
    "Uranium Sort (Helium strategy 1)",
    "Uranium Sort"
);
new function hydrogenSortRun(array) {
    HeliumSort().sort(array, 0, len(array), -1);
}

@Sort(
    "Block Merge Sorts",
    "Hydrogen Sort (Helium strategy 2A)",
    "Hydrogen Sort"
);
new function hydrogenSortRun(array) {
    HeliumSort().sort(array, 0, len(array), -2);
}