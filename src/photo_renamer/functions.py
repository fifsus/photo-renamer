import logging
import os
from datetime import datetime
from typing import Dict, List

from PIL import Image

from .photo import Photo

logger = logging.getLogger(__name__)

SUPPORTED_FILES = ["jpeg", "jpg"]


def get_app_path() -> str:
    return "."
    # This doesn't work as .exe dist
    # return str(pathlib.Path(__file__).parent.resolve())


def ask_rename_photos(path: str) -> str:
    response = input(
        f"\nDo you want to rename photos in the directory '{path}'? [Y/n] (default: n)\n\n"
    )
    if response and (response == "Y" or response == "y"):
        return path
    else:
        return ask_switch_directory(path)


def ask_switch_directory(path: str) -> str:
    print("\nAvailable directories:")
    print("----------------------")
    print("#\tName")
    directories: List[str] = []
    directories.append("..")
    print("0\t..")
    counter: int = 1

    for _, dirnames, _ in os.walk(path):
        for dirname in dirnames:
            directories.append(dirname)
            print(f"{counter}\t{dirname}")
            counter += 1
        break
    new_directory = str(
        input(
            "\nWhich directory do you want to search photos for? (type name or #)\n\n"
        )
    )

    new_directory_index: int = -1
    try:
        new_directory_index = int(new_directory)
    except ValueError:
        pass

    if new_directory in directories:
        return ask_rename_photos(os.path.join(path, new_directory))
    elif new_directory_index >= 0 and new_directory_index <= len(directories):
        return ask_rename_photos(os.path.join(path, directories[new_directory_index]))
    else:
        print(f"Unknown directory {new_directory}. Retry...")
        return ask_switch_directory(path)


def check_directory(path: str) -> None:
    photo_count: int = 0

    for _, _, files in os.walk(path):
        for file in files:
            file_extension = get_file_extension(file)
            if file_extension and file_extension.lower() in SUPPORTED_FILES:
                photo_count += 1
        # Stop the process to go deeper into subdirectories
        break

    print(
        f"There {'are' if photo_count > 1 else 'is'} {photo_count} {'photos' if photo_count > 1 else 'photo'} which {'have' if photo_count > 1 else 'has'} supported format and can be renamed."
    )


def get_file_extension(file_name: str) -> str:
    name: List[str] = file_name.split(".")
    return name[-1] if len(name) > 1 else ""


def get_current_directory_name(path: str) -> str:
    _, tail = os.path.split(path)
    return tail


def get_photo_date(photo_path: str) -> str:
    print(photo_path)
    photo: Image = Image.open(photo_path)
    date_taken: str = photo._getexif()[36867]
    date_mofified: str = photo._getexif()[306]
    dates: List[str] = [date_taken, date_mofified]
    dates = sorted(dates)
    return dates[0]


def get_photos_with_timestamps(path: str) -> Dict[str, Photo]:
    photos: Dict[str, Photo] = {}
    for _, _, files in os.walk(path):
        print(f"There are {len(files)} files.")
        for file in files:
            print(f"Processing file {file}")
            file_extension = get_file_extension(file)
            if file_extension and file_extension.lower() in SUPPORTED_FILES:
                photo_path: str = os.path.join(path, file)
                photo_date: str = get_photo_date(photo_path)
                if photo_date not in photos.keys():
                    photos[photo_date] = Photo(
                        photo_path, file, file_extension, photo_date
                    )
                else:
                    logger.warning(
                        f"Skipping photo {photo_path} with date {photo_date}, other photo {photos[photo_date].path} has the same timestamp."
                    )
        # Stop the process from going deeper into subdirectories
        break
    return photos


def prepare_photos(
    photos: Dict[str, Photo], sorted_keys: List[str], name_base: str
) -> Dict[str, Photo]:
    print(f"\n{'#'}\t{'TIMESTAMP':24}{'Original name':32}{'New name':32}")
    for i in range(len(sorted_keys)):
        photo: Photo = photos[sorted_keys[i]]
        number: int = 0

        # Get previous photo to know whether to add number
        if (i - 1) >= 0:
            prev_photo: Photo = photos[sorted_keys[i - 1]]
            if prev_photo.date == photo.date:
                number = prev_photo.number + 1

        # Get next photo to know whether or not to start with (1)
        if number == 0:
            if (i + 1) < len(sorted_keys):
                next_photo: Photo = photos[sorted_keys[i + 1]]
                if next_photo.date == photo.date:
                    number = 1
        photo.generate_name(name_base, number)
        print(f"{i + 1}\t{sorted_keys[i]:24}{photo.old_name:32}{photo.new_name:32}")
    return photos


def log_process(message_line: str) -> None:
    date = datetime.now()
    with open(os.path.join(get_app_path(), "photo-renamer.log"), "a") as file:
        file.write(f"{date} | {message_line}\n")


def rename_photos(current_directory: str, photos: Dict[str, Photo]) -> None:

    existing_files: List[str] = []
    for _, _, files in os.walk(current_directory):
        for file in files:
            existing_files.append(file)
        # Stop the process to go deeper into subdirectories
        break

    for photo in photos.values():
        if photo.new_name not in existing_files:
            print(f"Renaming {photo.old_name} to {photo.new_name}.")

            os.rename(
                os.path.join(current_directory, photo.old_name),
                os.path.join(current_directory, photo.new_name),
            )
            log_process(f"{current_directory } | {photo.old_name} -> {photo.new_name}")
        else:
            logger.error(
                f"Can't rename photo {photo.old_name} to {photo.new_name}. File {photo.new_name} already exists and it would get overwritten. Skipping..."
            )
    print("\nAll photos were renamed.")
