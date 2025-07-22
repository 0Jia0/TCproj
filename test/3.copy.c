int compute(int x, int y)
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
    int t = a32 + 11135;
    return t + y;
}

int main()
{
    int N = 20000000;
    int MOD = 998244353;
    ;

    int i = 0;
    int result = 0;
    while (i < N)
    {
        result = ((result + compute((i + 512080210) % 32768, (i + 863555673) % 32768) % MOD) % MOD - i % MOD) % MOD;
        i = i + 1;
    }
    return result;
}