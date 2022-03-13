from __future__ import annotations

import logging
from typing import Dict, List

from photo_renamer import functions as fun
from photo_renamer import photo

logger = logging.getLogger(__name__)

print("To exit early press Ctrl + C.")

# Get and print current path
current_path = fun.get_app_path()

print(f"\nYour current path is: '{current_path}'.")


current_path = fun.ask_rename_photos(current_path)

print(f"\nPhotos located at {current_path} will be renamed.")

fun.check_directory(current_path)

current_directory_name: str = fun.get_current_directory_name(current_path)
new_name: str = str(
    input(
        f"\nWhat name should all the photos be renamed to? (default: {current_directory_name})\n\n"
    )
)

photos: Dict[str, photo.Photo] = fun.get_photos_with_timestamps(current_path)
sorted_timestamps: List[str] = sorted(photos.keys())

prepared_photos: Dict[str, photo.Photo] = fun.prepare_photos(
    photos, sorted_timestamps, new_name
)


response = input(
    "\nDo you really want to rename photos as displayed above? [Y/n] (default: n)\n\n"
)
if response and (response == "Y" or response == "y"):
    print("\nRenaming photos, please wait...")
    fun.rename_photos(current_path, prepared_photos)
else:
    print("\nPhotos were not renamed.")

terminate = input("\nPress ENTER to exit.")

exit()
