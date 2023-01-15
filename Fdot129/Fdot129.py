import math

def sdrawkcab(frac, dp = 6):
    rev = 0
    for i in range(dp -1, -1, -1):
        rev += (int(frac * pow(10, i)) % 10) * pow(10, i - 1)
    return rev

def Fdot129(value, bit, n = 64, dp = 6):
    if bit == n:
        return 0 if str(value)[0] == "-" else 1 # (value < 0.0)
    elif bit < n:
        index = pow(2, n - bit)
        absol = math.floor(abs(value))
        return 1 if (absol % index) >= (index / 2) else 0
    elif bit > n:
        index = pow(2, bit - n)
        absol = sdrawkcab(abs(value) - math.floor(abs(value)))
        return 1 if (absol % index) >= (index / 2) else 0
    else:
        return 0

#print(sdrawkcab(0.12345))

value = -0.0
for i in range(0, 129):
    result = Fdot129(value, i)
    print(result, end = "")
