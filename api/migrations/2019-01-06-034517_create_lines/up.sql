CREATE TABLE lines (
    id         SERIAL    PRIMARY KEY,
    text       TEXT      NOT NULL,
    name       TEXT,
    email      TEXT,
    story_id   INT       NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

SELECT diesel_manage_updated_at('lines');
