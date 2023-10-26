def f(x):
    return x**5 - x - 0.2


def iteration(x1, x2):
    return x2, (x3 := x1 - f(x1) * (x2 - x1) / (f(x2) - f(x1))), abs(x3 - x2)


def meth(x1, x2, d):
    cd = 2 * d + 1e-8

    while cd > d:
        x1, x2, cd = iteration(x1, x2)

    return x2


if __name__ == '__main__':
    print(meth(1, 1.1, 0))
    print(meth(1.1, 1.2, 0))
    print(meth(-1, -0.5, 0))
    print(meth(-0.5, 0, 0))
    print(meth(-100, -10, 0))

