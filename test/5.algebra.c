int compute(int x, int y)
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

    return x + y - a - b - c - p - q + r;
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
        result = ((result + compute((i + 62138524) % 32768, (i + 237301429) % 32768) % MOD) % MOD - i % MOD) % MOD;
        i = i + 1;
    }
    return result;
}