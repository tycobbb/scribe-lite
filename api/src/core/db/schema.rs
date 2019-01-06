table! {
    lines (id) {
        id -> Int4,
        text -> Nullable<Varchar>,
        email -> Nullable<Varchar>,
        name -> Nullable<Varchar>,
    }
}

table! {
    schema_migrations (version) {
        version -> Int8,
        inserted_at -> Nullable<Timestamp>,
    }
}

table! {
    stories (id) {
        id -> Int4,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}

allow_tables_to_appear_in_same_query!(
    lines,
    schema_migrations,
    stories,
);
