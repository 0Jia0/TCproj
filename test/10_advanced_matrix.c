int mod(int a, int b)
{
    return ((a % b) + b) % b;
}

int fastPow(int base, int exp, int modulus)
{
    int result = 1;
    base = mod(base, modulus);

    while (exp > 0)
    {
        if (exp % 2 == 1)
        {
            result = mod(result * base, modulus);
        }
        base = mod(base * base, modulus);
        exp = exp / 2;
    }

    return result;
}

int matrixMultiplyTrace(int n, int seed)
{
    int a = 1664525;
    int c = 1013904223;
    int m = 1073741824; // 2 ^ 30

    int trace = 0;
    int i = 0;
    int j = 0;
    int k = 0;

    // 外层循环迭代 n 次
    while (i < n)
    {
        int subSum = 0;
        j = 0;

        // 计算 A[i][j] * B[j][i] 的和，即矩阵乘积的对角线元素
        while (j < n)
        {
            // 基于位置和种子生成矩阵 A 的元素
            int valA = mod((seed * a + i * n + j) * a + c, m);

            k = 0;
            int rowColProduct = 0;

            // 计算一个对角线元素
            while (k < n)
            {
                // 生成矩阵 A 和 B 的元素
                int elemA = mod((valA * (k + 1) + i) * a + c, m);
                int elemB = mod((valA * (k + 2) + j) * a + c, m);

                // 累加 A[i][k] * B[k][j]
                rowColProduct = rowColProduct + mod(elemA * elemB, m);

                k = k + 1;
            }

            // 只累加对角线元素（i == j）
            if (i == j)
            {
                subSum = subSum + mod(rowColProduct, m);
            }

            j = j + 1;
        }

        trace = trace + subSum;
        i = i + 1;
    }

    // 对结果进行一系列运算
    int finalResult = trace;
    i = 0;

    while (i < 100)
    {
        if (i % 2 == 0)
        {
            finalResult = mod(finalResult * 31 + 17, m);
        }
        else if (i % 3 == 0)
        {
            finalResult = mod(finalResult + fastPow(i + 1, 3, m), m);
        }
        else if (i % 5 == 0)
        {
            finalResult = mod(finalResult + (finalResult / 8), m);
        }
        else
        {
            finalResult = mod(finalResult * finalResult, m);

            // 避免数值过大，定期缩小
            if (finalResult > m / 2)
            {
                finalResult = finalResult / 17;
            }
        }

        i = i + 1;
    }

    return mod(finalResult, 256);
}

int main()
{
    int N = 400;
    int seed = 1378;

    return matrixMultiplyTrace(N, seed);
}