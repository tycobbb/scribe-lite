table! {
    lines (id) {
        id -> Int4,
        text -> Text,
        name -> Nullable<Text>,
        email -> Nullable<Text>,
        story_id -> Int4,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}

table! {
    stories (id) {
        id -> Int4,
        created_at -> Timestamp,
        updated_at -> Timestamp,
        queue -> Json,
    }
}

joinable!(lines -> stories (story_id));

allow_tables_to_appear_in_same_query!(
    lines,
    stories,
);
