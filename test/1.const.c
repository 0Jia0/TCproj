int compute(int x, int y)
{
    int a = 2789;
    int b = 24214;
    int c = -28311;
    int p = a + 14395;
    int q = b * 22331;
    int r = c - 79;
    int result = p * q / (r - 1);
    return result;
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
        result = ((result + compute((i + 924770053) % 32768, (i + 274116299) % 32768) % MOD) % MOD - i % MOD) % MOD;
        i = i + 1;
    }
    return result;
}