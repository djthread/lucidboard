

Twiddler.Op
===========
* Enhance move_items to allow moving between columns
* delete_orphan_piles logic

Twiddler Actions
================
* Set board properties (title, settings, ...)
* :add_card action - creates empty card in locked mode
  * inputs: column_id
* :move_card action
  * inputs: card_id, dest_column_id, dest_pile_pos, is_new_pile (bool)
* :delete_card
  * inputs: card_id
