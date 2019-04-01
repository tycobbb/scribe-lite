ALTER TABLE stories
  DROP COLUMN queue,
  ADD  COLUMN author_ids integer[];
