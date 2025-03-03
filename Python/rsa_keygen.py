import random
from sympy import isprime

# Generate prime numbers
def generate_prime(key_length):
    while True:
        num = random.getrandbits(key_length)
        if isprime(num):
            return num

# Generate RSA key pair
def generate_rsa_key(key_length):
    p = generate_prime(key_length)
    q = generate_prime(key_length)
    N = p * q
    phi_N = (p - 1) * (q - 1)
    # e = 65537  # commonly used public exponent
    e = generate_prime(key_length*2)  # random public exponent
    d = pow(e, -1, phi_N)  # modular multiplicative inverse of e modulo phi_N
    return e, d, N

# Specify the desired key length
key_length = 32  # Change this value as needed ex. RSA-256: 128 or smaller

# Generate RSA key pair
e, d, N = generate_rsa_key(key_length)


# Write the keys to a file
with open("./Test_data/RSA_key.txt", "w") as f:
    # e d N
    f.write(str(hex(e)[2:]) + " " + str(hex(d)[2:]) + " " + str(hex(N)[2:]))

# Print the keys
print("Public Exponent (e):", hex(e))
print("Private Exponent (d):", hex(d))
print("Modulus (N):", hex(N))
