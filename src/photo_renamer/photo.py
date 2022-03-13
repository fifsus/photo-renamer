class Photo:
    path: str
    date: str
    old_name: str
    new_name: str
    number: int
    extension: str

    def __init__(
        self, photo_path: str, old_name: str, extension: str, timestamp: str
    ) -> None:
        self.path = photo_path
        self.old_name = old_name
        self.extension = extension.lower()
        self.date = self.get_date_from_timestamp(timestamp)

    def generate_name(self, name_base: str, number: int) -> None:
        self.new_name = f"{self.date} {name_base}{' ('+str(number)+')' if number != 0 else ''}.{self.extension}"
        self.number = number

    def get_date_from_timestamp(self, timestamp: str) -> str:
        substring_date: str = timestamp[0:10]
        return substring_date.replace(":", "-")
