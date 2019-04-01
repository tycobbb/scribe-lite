ALTER TABLE stories
  DROP COLUMN author_ids,
  ADD  COLUMN queue json;
