import random
import binascii

def mod_exp(base, exponent, modulus):
    result = 1
    while exponent > 0:
        if exponent % 2 == 1:
            result = (result * base) % modulus
        exponent = exponent >> 1
        base = (base * base) % modulus
    return result

def gcd(a, b):
    while b:
        a, b = b, a % b
    return a

def extended_gcd(a, b):
    if a == 0:
        return b, 0, 1
    else:
        gcd, x, y = extended_gcd(b % a, a)
        return gcd, y - (b // a) * x, x

def mod_inverse(e, phi_n):
    gcd, x, y = extended_gcd(e, phi_n)
    if gcd != 1:
        raise ValueError("Modular inverse does not exist")
    else:
        return x % phi_n

def generate_rsa_keypair(key_size):
    # Generate two random prime numbers
    while True:
        p = random_prime(key_size)
        q = random_prime(key_size)
        if p != q:
            break

    n = p * q
    phi_n = (p - 1) * (q - 1)

    # Choose e such that 1 < e < phi(n) and gcd(e, phi(n)) = 1
    e = random.randint(2, phi_n - 1)
    while gcd(e, phi_n) != 1:
        e = random.randint(2, phi_n - 1)

    # Compute d = e^(-1) mod phi(n)
    d = mod_inverse(e, phi_n)

    # Convert keys to hexadecimal representation
    e_hex = hex(e)[2:]
    n_hex = hex(n)[2:]
    d_hex = hex(d)[2:]

    return (e_hex, n_hex), (d_hex, n_hex)

def random_prime(bits):
    while True:
        num = random.getrandbits(bits)
        if is_prime(num):
            return num

def is_prime(n, k=5):
    if n <= 1:
        return False
    elif n <= 3:
        return True
    elif n % 2 == 0 or n % 3 == 0:
        return False
    else:
        r, s = 0, n - 1
        while s % 2 == 0:
            r += 1
            s //= 2
        for _ in range(k):
            a = random.randrange(2, n - 1)
            x = mod_exp(a, s, n)
            if x == 1 or x == n - 1:
                continue
            for _ in range(r - 1):
                x = mod_exp(x, 2, n)
                if x == n - 1:
                    break
            else:
                return False
        return True

# 加密和解密函数
def encrypt(message, public_key):
    e, n = public_key
    message_int = int(binascii.hexlify(message.encode('utf-8')), 16)
    # ciphertext_int = mod_exp(message_int, int(e, 16), int(n, 16))
    # str(n.bit_length()) + " bits"
    print("n length = " + str(int(n, 16).bit_length()) + " bits")
    print("e length = " + str(int(e, 16).bit_length()) + " bits")
    ciphertext_int = pow(message_int, int(e, 16), int(n, 16))
    return hex(ciphertext_int)[2:]

def decrypt(ciphertext_hex, private_key):
    d, n = private_key
    ciphertext_int = int(ciphertext_hex, 16)
    # decrypted_int = mod_exp(ciphertext_int, int(d, 16), int(n, 16))
    decrypted_int = pow(ciphertext_int, int(d, 16), int(n, 16))
    decrypted_hex = hex(decrypted_int)[2:]
    decrypted_message = binascii.unhexlify(decrypted_hex).decode('utf-8')
    return decrypted_message

# 生成RSA密钥对
public_key, private_key = generate_rsa_keypair(512)
print("Public Key (e,n):", public_key)
print("Private Key (d,n):", private_key)

# 加密和解密示例
message = "Hello, world!"
print("Original Message:", message)

# 加密
ciphertext_hex = encrypt(message, public_key)
print("Encrypted Message (Hexadecimal):", ciphertext_hex)

# 解密
decrypted_message = decrypt(ciphertext_hex, private_key)
print("Decrypted Message:", decrypted_message)
