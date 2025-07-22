int compute(int x, int y)
{
    int a = x - y;
    int b = x - y;
    int z = a + b + (x - y) * (x - y);
    return x - y - z;
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
        result = ((result + compute((i + 283108171) % 32768, (i + 205929935) % 32768) % MOD) % MOD - i % MOD) % MOD;
        i = i + 1;
    }
    return result;
}