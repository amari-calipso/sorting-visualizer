# MIT License
#
# Copyright (c) 2022 aphitorite
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
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

$comptime
    if DEBUG_MODE {
        $exportBlock


# new wip implementation

use blockSwap, bidirArrayCopy, insertionSort, log2;

namespace LogSort {
    new classmethod productLog(n) {
        for r = 1; (r << r) + r - 1 < n; r++ {}
        return r;
    }

    new classmethod insertionSort(array, a, n) {
        insertionSort(array, a, a + n);
    }

    new classmethod quickSelect(array, a, n, p) {
        while n > 16 {
            new int a1 = a + n / 2,
                    a2 = a + n - 1;

            if array[a1] > array[a] {
                array[a1].swap(array[a]);
            }

            if array[a] > array[a2] {
                array[a].swap(array[a2]);
            }

            if array[a1] > array[a] {
                array[a1].swap(array[a]);
            }

            new int i = a,
                    j = a + n;

            while True {
                for i++; i <  j && array[i] < array[a]; i++ {}
                for j--; j >= i && array[j] > array[a]; j-- {}

                if i < j {
                    array[i].swap(array[j]);
                } else {
                    array[a].swap(array[j]);
                    break;
                }
            }

            new int m = j - a;
            if p < m {
                n = m;
            } elif p > m {
                n -= m + 1;
                p -= m + 1;
                a  = j + 1;
            } else {
                return;
            }
        }

        this.insertionSort(array, a, n);
    }

    new classmethod medianOf9(array, swap, a, n) {
        new int s = (n - 1) // 8;

        for i = 0, j = a; i < 9; i++, j += s {
            swap[i].write(array[j]);
        }
        insertionSort(swap, 0, 9);

        return swap[4].copy();
    }

    new classmethod smartMedian(array, swap, a, n, bLen) {
        for cbrt = 32; cbrt * cbrt * cbrt < n && cbrt < 1024; cbrt *= 2 {}

        new int d = min(bLen, cbrt);
        d -= d % 2;
        new int s = n // d;

        for i = 0, j = a + int(random.random() * s); i < d; i++, j += s {
            swap[i].write(array[j]);
        }

        this.quickSelect(swap, 0, d, d // 2);

        return swap[d // 2].copy();
    }

    new classmethod blockRead(array, a, piv, wLen, pCmp) {
        new int r = 0,
                i = 0;

        for ; wLen > 0; a++, i++ {
            wLen--;
            r |= int(compareValues(array[a], piv) < pCmp) << i;
        }

        return r;
    }

    new classmethod blockXor(array, a, b, v) {
        for ; v > 0; v >>= 1, a++, b++ {
            if (v & 1) > 0 {
                array[a].swap(array[b]);
            }
        }
    }

    new classmethod partitionEasy(array, swap, a, n, piv, pCmp) {
        new int p  = a,
                ps = 0;

        for i = n; i > 0; i--, p++ {
            if compareValues(array[p], piv) < pCmp {
                array[a].write(array[p]);
                a++;
            } else {
                swap[ps].swap(array[p]);
                ps++;
            }
        }

        bidirArrayCopy(swap, 0, array, a, ps);
        return a;
    }

    new classmethod partition(array, swap, a, n, bLen, piv, pCmp) {
        if n <= bLen {
            return this.partitionEasy(array, swap, a, n, piv, pCmp);
        }

        new int p  = a,
                l  = 0,
                r  = 0,
                lb = 0,
                rb = 0;

        for i = 0; i < n; i++ {
            if compareValues(array[a + i], piv) < pCmp {
                array[p + l].write(array[a + i]);
                l++;
            } else {
                swap[r].write(array[a + i]);
                r++;
            }

            if l == bLen {
                p += bLen;
                l = 0;
                lb++;
            }

            if r == bLen {
                bidirArrayCopy(array, p, array, p + bLen, l);
                bidirArrayCopy(swap, 0, array, p, bLen);
                p += bLen;
                r = 0;
                rb++;
            }
        }

        bidirArrayCopy(swap, 0, array, p + l, r);

        new bool x = lb < rb;
        new int min_ = lb if x else rb,
                m    = a + lb * bLen;

        if min_ > 0 {
            new int max_ = lb + rb - min_,
                    wLen = log2(min_) - 1,
                    j    = a,
                    k    = a,
                    v    = 0;

            for i = min_; i > 0; i--, v++, j += bLen, k += bLen {
                for ; !(compareValues(array[j + wLen], piv) < pCmp); j += bLen {}
                for ;   compareValues(array[k + wLen], piv) < pCmp;  k += bLen {}
                this.blockXor(array, j, k, v);
            }

            j = p - bLen if x else a;
            k = j;
            new int s = (-bLen) if x else bLen;

            for i = max_; i > 0; k += s {
                if x ^ (compareValues(array[k + wLen], piv) < pCmp) {
                    blockSwap(array, j, k, bLen);
                    j += s;
                    i--;
                }
            }

            j = 0;
            new int ps   = a if x else m,
                    pa   = ps,
                    pb   = m if x else a,
                    mask = (int(x) << wLen) - int(x);

            for i = min_; i > 0; i-- {
                k = mask ^ this.blockRead(array, ps, piv, wLen, pCmp);

                while j != k {
                    blockSwap(array, ps, pa + k * bLen, bLen);
                    k = mask ^ this.blockRead(array, ps, piv, wLen, pCmp);
                }

                this.blockXor(array, ps, pb, j);
                j++; ps += bLen; pb += bLen;
            }
        }

        if l > 0 {
            bidirArrayCopy(array, p, swap, 0, l);
            bidirArrayCopy(array, m, array, m + l, rb * bLen);
            bidirArrayCopy(swap, 0, array, m, l);
        }

        return m + l;
    }

    new classmethod logSort(array, swap, a, n, bLen) {
        while n > 24 {
            new Value piv = this.medianOf9(array, swap, a, n) if n < 2048
                            else this.smartMedian(array, swap, a, n, bLen);

            new int p = this.partition(array, swap, a, n, bLen, piv, 1),
                    m = p - a;
            
            if m == n {
                p = this.partition(array, swap, a, n, bLen, piv, 0);
                n = p - a;
                continue;
            }

            this.logSort(array, swap, p, n - m, bLen);
            n = m;
        }

        this.insertionSort(array, a, n);
    }

    new classmethod sort(array, a, n, bLen) {
        bLen = max(9, min(n, bLen));
        new list swap = sortingVisualizer.createValueArray(bLen);
        sortingVisualizer.setAux(swap);

        this.logSort(array, swap, a, n, bLen);
    }
}


        $end
    } else {
        $exportBlock


use blockSwap, arrayCopy, log2, medianOfMedians,
    medianOf9, binaryInsertionSort, reverseArrayCopy;

namespace LogSort {
    new classmethod productLog(n) {
        for r = 1; (r << r) + r - 1 < n; r++ {}
        return r;
    }

    new classmethod pivCmp(v, piv, pCmp) {
        return compareValues(v, piv) < pCmp;
    }

    new classmethod pivBufSet(array, pa, pb, v, wLen) {
        while wLen > 0 {
            wLen--;
            if (v & 1) == 1 {
                array[pa + wLen].swap(array[pb + wLen]);
            }

            v >>= 1;
        }
    }

    new classmethod pivBufGet(array, pa, piv, pCmp, wLen, bit) {
        new int r = 0;

        while wLen > 0 {
            wLen--;
            r <<= 1;
            r |= bit if this.pivCmp(array[pa], piv, pCmp) else (bit ^ 1);
            pa++;
        }

        return r;
    }

    new classmethod partitionEasy(array, aux, a, b, piv, pCmp) {
        new int j = 0;

        for i = a; i < b; i++ {
            if this.pivCmp(array[i], piv, pCmp) {
                array[a].write(array[i]);
                a++;
            } else {
                aux[j].write(array[i]);
                j++;
            }
        }

        arrayCopy(aux, 0, array, a, j);
        return a;
    }

    new classmethod blockPartition(array, aux, a, b, bLen, piv, pCmp) {
        if b - a <= bLen {
            return this.partitionEasy(array, aux, a, b, piv, pCmp);
        }

        new int p  = a,
                l  = 0,
                r  = 0,
                lb = 0,
                rb = 0;

        for i = a; i < b; i++ {
            if this.pivCmp(array[i], piv, pCmp) {
                array[p + l].write(array[i]);
                l++;

                if l == bLen {
                    l = 0;
                    lb++;
                    p += bLen;
                }
            } else {
                aux[r].write(array[i]);
                r++;

                if r == bLen {
                    arrayCopy(array, p, array, p + bLen, l);
                    arrayCopy(aux, 0, array, p, bLen);
                    r = 0;
                    rb++;
                    p += bLen;
                }
            }
        }

        new int min_ = min(lb, rb),
                m    = a + lb * bLen;

        if min_ > 0 {
            new int bCnt = lb + rb,
                    wLen = log2(min_ - 1) + 1;

            for i = 0, j = 0, k = 0; i < min_; i++ {
                for ; !this.pivCmp(array[a + j * bLen + wLen], piv, pCmp); j++ {}
                for ;  this.pivCmp(array[a + k * bLen + wLen], piv, pCmp); k++ {}
                this.pivBufSet(array, a + j * bLen, a + k * bLen, i, wLen);
                j++; k++;
            }


            if lb < rb {
                for i = bCnt - 1, j = 0; j < rb; i-- {
                    if !this.pivCmp(array[a + i * bLen + wLen], piv, pCmp) {
                        j++;
                        blockSwap(array, a + i * bLen, a + (bCnt - j) * bLen, bLen);
                    }
                }

                for i = 0; i < lb; i++ {
                    new int dest = this.pivBufGet(array, a + i * bLen, piv, pCmp, wLen, 0);

                    while dest != i {
                        blockSwap(array, a + i * bLen, a + dest * bLen, bLen);
                        dest = this.pivBufGet(array, a + i * bLen, piv, pCmp, wLen, 0);
                    }

                    this.pivBufSet(array, a + i * bLen, m + i * bLen, i, wLen);
                }
            } else {
                for i = 0, j = 0; j < lb; i++ {
                    if this.pivCmp(array[a + i * bLen + wLen], piv, pCmp) {
                        blockSwap(array, a + i * bLen, a + j * bLen, bLen);
                        j++;
                    }
                }

                for i = 0; i < rb; i++ {
                    new int dest = this.pivBufGet(array, m + i * bLen, piv, pCmp, wLen, 1);

                    while dest != i {
                        blockSwap(array, m + i * bLen, m + dest * bLen, bLen);
                        dest = this.pivBufGet(array, m + i * bLen, piv, pCmp, wLen, 1);
                    }

                    this.pivBufSet(array, a + i * bLen, m + i * bLen, i, wLen);
                }
            }
        }

        arrayCopy(aux, 0, array, b - r, r);

        if l > 0 {
            arrayCopy(array, b - r - l, aux, 0, l);
            reverseArrayCopy(array, a + lb * bLen, array, a + lb * bLen + l, rb * bLen);
            arrayCopy(aux, 0, array, a + lb * bLen, l);
        }

        return a + lb * bLen + l;
    }

    new classmethod logSort(array, aux, a, b, bLen, badPartition) {
        while b - a > 32 {
            new int p;
            if badPartition {
                new int n = b - a;
                n -= ~n & 1;
                p = medianOfMedians(array, a, n);
                badPartition = False;
            } else {
                p = medianOf9(array, a, b);
            }

            new int m = this.blockPartition(array, aux, a, b, bLen, array[p].copy(), 0);
            new int left  = m - a,
                    right = b - m;

            if m == a {
                m = this.blockPartition(array, aux, a, b, bLen, array[p].copy(), 1);
                badPartition = left * 8 < right;
                a = m;
            } else {
                if right < left {
                    badPartition = right * 8 < left;
                    this.logSort(array, aux, m, b, bLen, badPartition);
                    b = m;
                } else {
                    badPartition = left * 8 < right;
                    this.logSort(array, aux, a, m, bLen, badPartition);
                    a = m;
                }
            }
        }

        binaryInsertionSort(array, a, b);
    }

    new classmethod sort(array, a, b, cBLen) {
        new int bLen = max(this.productLog(b - a), min(cBLen, b - a));
        new list aux = sortingVisualizer.createValueArray(bLen);
        sortingVisualizer.setAux(aux);

        this.logSort(array, aux, a, b, bLen, False);
    }
}


        $end
    }
$end

@Sort(
    "Quick Sorts",
    "Log Sort",
    "Log Sort"
);
new function logSortRun(array) {
    new int bLen = sortingVisualizer.getUserInput(
        "Set block size (default: calculates minimum block length for current length)", 
        str(LogSort.productLog(len(array)))
    );

    LogSort.sort(array, 0, len(array), bLen);
}