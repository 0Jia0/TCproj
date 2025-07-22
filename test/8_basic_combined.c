int loopSideEffect(int n, int x)
{
    int i = 0;
    int acc = 0;
    while (i < n)
    {
        acc = acc + i;
        i = i + 1;
    }
    return x;
}

int loop(int n, int x, int y)
{
    int MOD = 998244353;

    int i = 0;
    int result = 0;
    while (i < n)
    {
        int t1 = x * 3 + 1;
        int t2 = y * 2 + 1;
        int t3 = t1 + t2;

        int t4 = 0;
        int j = 0;
        while (j < 10)
        {
            t4 = loopSideEffect(5, t4) + t3;
            j = j + 1;
        }
        int t5 = t1 + t2 + t3 + t4;

        int t6 = t4 + t5;

        int t7 = 0;
        {
            int a = 4825;
            int b = 88;
            int c = -31877;
            int p = a + 32455;
            int q = b * 13153;
            int r = c - 30391;
            int result = p * q / (r - 1);
            t7 = result;
        }

        int t8 = 0;
        {
            int a = 9133;
            int b = -8386;
            int c = -16338;

            int unused1 = a + b;
            int unused2 = b * c;
            int unused3 = a - c;

            if (0)
            {
                a = a + 1;
                b = b + 2;
                c = c + 3;
            }

            int i = 0;
            while (i < 10)
            {
                int temp = i * i;
                i = i + 1;
            }

            t8 = a + b + c;
        }

        int t9 = 0;
        {
            int a1 = x;
            int a2 = a1;
            int a3 = a2;
            int a4 = a3;
            int a5 = a4;
            int a6 = a5;
            int a7 = a6;
            int a8 = a7;
            int a9 = a8;
            int a10 = a9;
            int a11 = a10;
            int a12 = a11;
            int a13 = a12;
            int a14 = a13;
            int a15 = a14;
            int a16 = a15;
            int a17 = a16;
            int a18 = a17;
            int a19 = a18;
            int a20 = a19;
            int a21 = a20;
            int a22 = a21;
            int a23 = a22;
            int a24 = a23;
            int a25 = a24;
            int a26 = a25;
            int a27 = a26;
            int a28 = a27;
            int a29 = a28;
            int a30 = a29;
            int a31 = a30;
            int a32 = a31;
            int t = a32 + 1823;
            t9 = t + y;
        }

        int t10 = 0;
        {
            int a = x - y;
            int b = x - y;
            int z = a + b + (x - y) * (x - y);
            t10 = x - y - z;
        }

        int t11 = 0;
        {
            int a = x * 1;
            int b = a + 0;
            int c = b * 0;

            int p = y / 1;
            int q = x * 16;
            int r = y / 8;
            int s = x - 0;
            int t = y / 32;

            int u = -b + (a + b);
            int v = p - q - r + r;
            int w = s - (b - b) - t;

            t11 = x + y + a - b + c - p + q - r;
        }

        int t12 = ((((t7 + t8) % MOD + t9) % MOD + t10) % MOD + t11) % MOD;

        result = ((result + t12 % MOD) % MOD - i % MOD) % MOD;
        i = i + 1;
    }
    return result;
}

int main()
{
    int N = 20000000;

    return loop(N, 7723, -11682);
}