class Walker:
    def walk(self, items):
        for item in items:
            if item > 1:
                print(item)
        return len(items)
