int loop(int n, int x, int y)
{
    int MOD = 998244353;

    int i = 0;
    int result = 0;
    while (i < n)
    {
        int t1 = x * 2 + 1;
        int t2 = y * 3 + 1;
        int t3 = t1 - t2;

        int t4 = 0;
        int t5 = 0;
        int j = 0;
        while (j < 10)
        {
            int k = 0;
            t5 = 0;
            while (k < 5)
            {
                t5 = t5 + t3;
                k = k + 1;
            }
            t4 = t1 + t2 + t3;
            j = j + 1;
        }

        int t6 = t4 - t5;

        result = ((result + t6 % MOD) % MOD - i % MOD) % MOD;
        i = i + 1;
    }
    return result;
}

int main()
{
    int N = 20000000;

    return loop(N, -8635, -15533);
}