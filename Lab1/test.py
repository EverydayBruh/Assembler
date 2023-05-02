a = 2147483640
b = -32767
c = -32767
d = 32767
e = 2147483640
print(a * (b + c))
print(d * (e + a))
print((a * (b + c) - d * (e + a)))
print((d * d - c * c * b))
print((a * (b + c) - d * (e + a)) / (d * d - c * c * b))