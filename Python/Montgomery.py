import binascii
class BigIntegerDemo:
    def __init__(self):
        self.one = 1
        self.NUM_BITS = 512

    def ModExp(self, M, e, n, Mbar, xbar):
        for i in range(self.NUM_BITS - 1, -1, -1):
            # square
            xbar = self.montMult(xbar, xbar, n)

            # multiply
            if e >> i & 1:
                xbar = self.montMult(Mbar, xbar, n)

        # undo montgomery residue transformation
        return self.montMult(xbar, self.one, n)

    def montMult(self, X, Y, M):
        S = 0

        for i in range(self.NUM_BITS):
            # add product of X.get_bit(i) and Y to partial sum
            if X >> i & 1:
                S += Y  # S += X[i]*Y

            # if S is even, add modulus to partial sum
            if S & 1:
                S += M

            # rightshift 1 bit (divide by 2)
            S >>= 1

        # bring back to under 1024 bits by subtracting modulus
        if S >= M:
            S -= M

        return S

    def main(self):
        testcase = 0

        Mstr, estr, nstr, Mbarstr, xbarstr = "", "", "", "", ""

        print("NUM_BITS = " + str(self.NUM_BITS))

        switch_cases = {
            # 1024: {
            #     "Mstr": "00be5416af9696937b7234421f7256f78dba8001c80a5fdecdb4ed761f2b7f955946ec920399f23ce9627f66286239d3f20e7a46df185946c6c8482e227b9ce172dd518202381706ed0f91b53c5436f233dec27e8cb46c4478f0398d2c254021a7c21596b30f77e9886e2fd2a081cadd3faf83c86bfdd6e9daad12559f8d2747",
            #     "estr": "6f1e6ab386677cdc86a18f24f42073b328847724fbbd293eee9cdec29ac4dfe953a4256d7e6b9abee426db3b4ddc367a9fcf68ff168a7000d3a7fa8b9d9064ef4f271865045925660fab620fad0aeb58f946e33bdff6968f4c29ac62bd08cf53cb8be2116f2c339465a64fd02517f2bafca72c9f3ca5bbf96b24c1345eb936d1",
            #     "nstr": "b4d92132b03210f62e52129ae31ef25e03c2dd734a7235efd36bad80c28885f3a9ee1ab626c30072bb3fd9906bf89a259ffd9d5fd75f87a30d75178b9579b257b5dca13ca7546866ad9f2db0072d59335fb128b7295412dd5c43df2c4f2d2f9c1d59d2bb444e6dac1d9cef27190a97aae7030c5c004c5aea3cf99afe89b86d6d",
            #     "Mbarstr": "9A9D95D8EE88E38C18FF90DCDDFA8D8B59E8E3457F635660241E4B0CB01AD15CFDB7727BE260BA7254001D0D1B0DF4335927FE9332B9409A3B3D8F6DA56DE4ED030A9DAF7364871E5E46A01E174D36BEF53BB2C823A3301027168A23E67F5ABE4F7E1C3B2D75862C822D1B26593402E8835719CA67428A1F4020F14379EBB84D",
            #     "xbarstr": "4B26DECD4FCDEF09D1ADED651CE10DA1FC3D228CB58DCA102C94527F3D777A0C5611E549D93CFF8D44C0266F940765DA600262A028A0785CF28AE8746A864DA84A235EC358AB97995260D24FF8D2A6CCA04ED748D6ABED22A3BC20D3B0D2D063E2A62D44BBB19253E26310D8E6F5685518FCF3A3FFB3A515C306650176479293",
            # },
            512: {
                "Mstr": "2a15f2915127d80acfe718d9e8ca20591cd096d1910848cb50f87e2fbb52f2ab4805f436c3e1da4b1358a10a1758f9763324a60001336e37b985f91e2723c061968774c8a8b0a2b95f616a1a438db45a87caab12f606d726a095f5722556006f965f99392c89fdef13d9b48b0df7d5479ebed6e373e2ae3b71667c84560cb9bb",
                "estr": "2ee910088e3c88bd757538b8bf0858fb75b72dbc09dc33c75444ef6aa28b9112ab38bfbc42e93c3f2a7c1a12c298b9fd801d51b1a77470d8c14587301494ec160446ce12f772ede530d88585ab6a393d4754d29fe50a2e1d00244ab861150d55dfeeb546d7819cbd286b5edbe4776a0a39ec85e727cc93533ed9ba0810a9c747",
                "nstr": "a28eb9b7d20b7e65be4a7e902546319f5268bb0adb515eead910ce0b882f3ca6cf348b5d1dac78f974670740c99664a384395089627330a9946becbea96332b0bc81fe1a42e1962e79ba2862ec7e87d9a42c2da4496210f07a97a0abfac5899f26ea7ec9eef137b592b480694706090c13b891aeefea873aaeda5dee9d7e079b",
                "Mbarstr": "",
                "xbarstr": "",
            },
            2048: {
                "Mstr": "aba5e025b607aa14f7f1b8cc88d6ec01c2d17c536508e7fa10114c9437d9616c9e1c689a4fc54744fa7dfe66d6c2fcf86e332bfd6195c13fe9e331148013987a947d9556a27a326a36c84fb38bfefa0a0ffa2e121600a4b6aa4f9ad2f43fb1d5d3eb5eaba13d3b382fed0677df30a089869e4e93943e913d0dc099aa320b8d8325b2fc5a5718b19254775917ed48a34e86324adbc8549228b5c7beeefa86d27a44ceb204be6f315b138a52ec714888c8a699f6000d1cd5ab9bf261373a5f14da1f568be70a0c97c2c3eff0f73f7ebd47b521184dc3ca932c91022bf86dd029d21c660c7c6440d3a3ae799097642f0507dfaecac11c2bd6941cbc66cedeeab744",
                "estr": "9cf3af731abb784d81d8401c474a5282d1e6e3776496aed12167ea5eaae66dd3ac7d52cfe4c9db42c8546d2eb6bef113b97e7dec07ac46f5eb5df9e5d29df63bee53317639b1894e7465cc78db88a37d7e910ffc734987113a9b9d891089a92897c08d19d045211707f70cdd6f06af41ce916915e1ad00fb63936f41de204410ba04442eddd6c091e2037f53ff511c2ece8db357f34c8c2b50ea429b5d84ce94eb50d136e91b52e253099bc8a1e1649e88f3d898ef5ce2978f3a09e5f95b988d96396fd6726b18aa4594d87fe49159ce8383c9c4b52f322a7968f99d83a4a16eac1296d5e016c79e420f13ad05ba3772734066b260e8e8b7372aee1fcd3d08d9",
                "nstr": "d27bf9f01e2a901db957879f45f697330d21a21095da4fa7d3aab75454a8e9f0f4ea531ece34f0c3ba9e02eb27d8f0dbe78eede4ac84061beef162d00b55c0dd772d28f23e994899aa19b9bea7b12a8027a32a92190a3630e249544675488121565a23548fcd36f5382eeb993db9ce3f526f20ab355e82d963d59541bc1161e211a03e3b372560840c57e12bd2f40eac5ffcec01b3f07c378c0a60b74bef7b572764c88a4f98b61fa8ccd905afae779e6193378304d8eb17695ce71a173ac3de11271753c48db58546e5af9917c1cebba5bb1af3fce3df9516c0c95c9bc14bb65d1c53078c06c81ac0f3ed0d8634260e47bf780cf4f4996084df732935194417",
                "Mbarstr": "",
                "xbarstr": "",
            }
        }

        if self.NUM_BITS in switch_cases:
            case = switch_cases[self.NUM_BITS]
            Mstr, estr, nstr, Mbarstr, xbarstr = case["Mstr"], case["estr"], case["nstr"], case["Mbarstr"], case["xbarstr"]
        else:
            print("ERROR: Please supply valid modulus bit length (1024, 2048, etc...)")
            return

        M = int(Mstr, 16)
        e = int(estr, 16)
        n = int(nstr, 16)

        r = 2 ** self.NUM_BITS

        print("Modulus = " + str(n.bit_length()) + " bits")
        print("Exponent = " + str(e.bit_length()) + " bits")

        print("\nMontgomery Residue Transformation:")
        print("r = 2^" + str(self.NUM_BITS) + " = 0x" + format(r, 'x'))
        print("n length = " + str(n.bit_length()) + " bits")

        Mbar = M * r % n
        xbar = r % n

        sol = pow(M, e, n)

        print("\nActual solution = " + str(sol))
        print("\nInitial Values:")
        print('\t' + "M = 0x" + format(M, 'x'))
        print('\t' + "e = 0x" + format(e, 'x'))
        print('\t' + "n = 0x" + format(n, 'x'))
        print("\nComputed Values:")
        print('\t' + "Mbar (" + str(Mbar.bit_length()) + " bits) = 0x" + format(Mbar, 'x'))
        print('\t' + "xbar (" + str(xbar.bit_length()) + " bits) = 0x" + format(xbar, 'x'))

        mySol = self.ModExp(M, e, n, Mbar, xbar)
        print("\nComputed Montgomery Result: " + str(mySol))

        if sol != mySol:
            print("\nFAILURE: Montgomery solution does not match modexp solution!")
        else:
            print("mysol = " + str(mySol))
            print("\nPlaintext = ", bytes.fromhex(hex(mySol)[2:]).decode())
            print("********SUCCESS********!")


if __name__ == "__main__":
    demo = BigIntegerDemo()
    demo.main()
