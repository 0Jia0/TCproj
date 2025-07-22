int sum(int n, int acc)
{
    if (n <= 0)
    {
        return acc;
    }

    int new_acc;
    if (n % 2 == 0)
    {
        new_acc = ((acc - 1 - 2 - n % 2) % 5) * 9997 / 19;
    }
    else
    {
        new_acc = ((acc + 1 + 2 + n % 4) % 7) * 9997 / 17;
    }

    return sum(n - 1, new_acc);
}

int main()
{
    int N = 20000000;
    int M = 10000;
    int MOD = 998244353;
    ;

    int result = 0;
    int i = 0;
    int n = N / M;
    while (i < n)
    {
        result = (result + sum(M, 0) % MOD + 609826728) % MOD;
        i = i + 1;
    }

    return result;
}