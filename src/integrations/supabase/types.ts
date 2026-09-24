export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      chat_participants: {
        Row: {
          chat_id: string
          joined_at: string
          user_id: string
        }
        Insert: {
          chat_id: string
          joined_at?: string
          user_id: string
        }
        Update: {
          chat_id?: string
          joined_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "chat_participants_chat_id_fkey"
            columns: ["chat_id"]
            isOneToOne: false
            referencedRelation: "chats"
            referencedColumns: ["id"]
          },
        ]
      }
      chats: {
        Row: {
          created_at: string
          id: string
          last_message: string | null
          last_message_at: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          last_message?: string | null
          last_message_at?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          last_message?: string | null
          last_message_at?: string | null
        }
        Relationships: []
      }
      friendships: {
        Row: {
          id: string
          requester_id: string
          addressee_id: string
          status: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          requester_id: string
          addressee_id: string
          status?: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          requester_id?: string
          addressee_id?: string
          status?: string
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      groups: {
        Row: {
          id: string
          name: string
          description: string | null
          color: string | null
          created_by: string
          is_public: boolean
          chat_enabled: boolean
          bio: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          description?: string | null
          color?: string | null
          created_by: string
          is_public?: boolean
          chat_enabled?: boolean
          bio?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          description?: string | null
          color?: string | null
          created_by?: string
          is_public?: boolean
          chat_enabled?: boolean
          bio?: string | null
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      group_members: {
        Row: {
          group_id: string
          user_id: string
          role: string
          joined_at: string
        }
        Insert: {
          group_id: string
          user_id: string
          role?: string
          joined_at?: string
        }
        Update: {
          group_id?: string
          user_id?: string
          role?: string
          joined_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "group_members_group_id_fkey"
            columns: ["group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
        ]
      }
      group_invitations: {
        Row: {
          id: string
          group_id: string
          inviter_id: string
          invitee_id: string
          status: string
          created_at: string
        }
        Insert: {
          id?: string
          group_id: string
          inviter_id: string
          invitee_id: string
          status?: string
          created_at?: string
        }
        Update: {
          id?: string
          group_id?: string
          inviter_id?: string
          invitee_id?: string
          status?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "group_invitations_group_id_fkey"
            columns: ["group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
        ]
      }
      group_messages: {
        Row: {
          id: string
          group_id: string
          sender_id: string
          body: string
          created_at: string
        }
        Insert: {
          id?: string
          group_id: string
          sender_id: string
          body: string
          created_at?: string
        }
        Update: {
          id?: string
          group_id?: string
          sender_id?: string
          body?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "group_messages_group_id_fkey"
            columns: ["group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
        ]
      }
      group_join_requests: {
        Row: {
          id: string
          group_id: string
          user_id: string
          status: string
          created_at: string
        }
        Insert: {
          id?: string
          group_id: string
          user_id: string
          status?: string
          created_at?: string
        }
        Update: {
          id?: string
          group_id?: string
          user_id?: string
          status?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "group_join_requests_group_id_fkey"
            columns: ["group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
        ]
      }
      message_reads: {
        Row: {
          chat_id: string
          message_id: string
          read_at: string
          user_id: string
        }
        Insert: {
          chat_id: string
          message_id: string
          read_at?: string
          user_id: string
        }
        Update: {
          chat_id?: string
          message_id?: string
          read_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "message_reads_chat_id_fkey"
            columns: ["chat_id"]
            isOneToOne: false
            referencedRelation: "chats"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "message_reads_message_id_fkey"
            columns: ["message_id"]
            isOneToOne: false
            referencedRelation: "messages"
            referencedColumns: ["id"]
          },
        ]
      }
      messages: {
        Row: {
          body: string
          chat_id: string
          created_at: string
          id: string
          sender_id: string
        }
        Insert: {
          body: string
          chat_id: string
          created_at?: string
          id?: string
          sender_id: string
        }
        Update: {
          body?: string
          chat_id?: string
          created_at?: string
          id?: string
          sender_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "messages_chat_id_fkey"
            columns: ["chat_id"]
            isOneToOne: false
            referencedRelation: "chats"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          account_type: string
          avatar_url: string | null
          bio: string | null
          created_at: string
          education_group_id: string | null
          email: string | null
          entrance_score: number | null
          first_name: string
          founded_date: string | null
          group_number: number | null
          id: string
          interests: string[] | null
          is_admin: boolean | null
          last_name: string
          last_seen: string | null
          message_privacy: string | null
          password: string | null
          profession: string | null
          specialty_id: string | null
          university_id: string | null
          updated_at: string
          verification_status: string | null
          year: string | null
        }
        Insert: {
          account_type?: string
          avatar_url?: string | null
          bio?: string | null
          created_at?: string
          education_group_id?: string | null
          email?: string | null
          entrance_score?: number | null
          first_name?: string
          founded_date?: string | null
          group_number?: number | null
          id: string
          interests?: string[] | null
          is_admin?: boolean | null
          last_name?: string
          last_seen?: string | null
          message_privacy?: string | null
          password?: string | null
          profession?: string | null
          specialty_id?: string | null
          university_id?: string | null
          updated_at?: string
          verification_status?: string | null
          year?: string | null
        }
        Update: {
          account_type?: string
          avatar_url?: string | null
          bio?: string | null
          created_at?: string
          education_group_id?: string | null
          email?: string | null
          entrance_score?: number | null
          first_name?: string
          founded_date?: string | null
          group_number?: number | null
          id?: string
          interests?: string[] | null
          is_admin?: boolean | null
          last_name?: string
          last_seen?: string | null
          message_privacy?: string | null
          password?: string | null
          profession?: string | null
          specialty_id?: string | null
          university_id?: string | null
          updated_at?: string
          verification_status?: string | null
          year?: string | null
        }
        Relationships: []
      }
      universities: {
        Row: {
          id: string
          name: string
          short_name: string
          created_at: string
        }
        Insert: {
          id?: string
          name: string
          short_name: string
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          short_name?: string
          created_at?: string
        }
        Relationships: []
      }
      education_groups: {
        Row: {
          id: string
          name: string
          created_at: string
        }
        Insert: {
          id?: string
          name: string
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          created_at?: string
        }
        Relationships: []
      }
      specialties: {
        Row: {
          id: string
          university_id: string
          education_group_id: string
          code: string
          name: string
          created_at: string
        }
        Insert: {
          id?: string
          university_id: string
          education_group_id: string
          code: string
          name: string
          created_at?: string
        }
        Update: {
          id?: string
          university_id?: string
          education_group_id?: string
          code?: string
          name?: string
          created_at?: string
        }
        Relationships: []
      }
      verification_requests: {
        Row: {
          id: string
          user_id: string | null
          first_name: string
          last_name: string
          university: string
          image_data: string
          status: string
          created_at: string
          reviewed_at: string | null
          reviewer_note: string | null
        }
        Insert: {
          id?: string
          user_id?: string | null
          first_name: string
          last_name: string
          university: string
          image_data: string
          status?: string
          created_at?: string
          reviewed_at?: string | null
          reviewer_note?: string | null
        }
        Update: {
          id?: string
          user_id?: string | null
          first_name?: string
          last_name?: string
          university?: string
          image_data?: string
          status?: string
          created_at?: string
          reviewed_at?: string | null
          reviewer_note?: string | null
        }
        Relationships: []
      }
      company_job_postings: {
        Row: {
          id: string
          company_id: string
          title: string
          field: string
          level: string
          description: string
          salary: string | null
          created_at: string
        }
        Insert: {
          id?: string
          company_id: string
          title: string
          field: string
          level: string
          description: string
          salary?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          company_id?: string
          title?: string
          field?: string
          level?: string
          description?: string
          salary?: string | null
          created_at?: string
        }
        Relationships: []
      }
      job_applications: {
        Row: {
          id: string
          job_id: string
          student_id: string
          message: string | null
          created_at: string
        }
        Insert: {
          id?: string
          job_id: string
          student_id: string
          message?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          job_id?: string
          student_id?: string
          message?: string | null
          created_at?: string
        }
        Relationships: []
      }
      field_categories: {
        Row: {
          id: string
          label: string
          sort_order: number
          is_active: boolean
          created_at: string
        }
        Insert: {
          id: string
          label: string
          sort_order?: number
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          label?: string
          sort_order?: number
          is_active?: boolean
          created_at?: string
        }
        Relationships: []
      }
      fields: {
        Row: {
          id: string
          category_id: string
          label: string
          sort_order: number
          is_active: boolean
          created_at: string
        }
        Insert: {
          id: string
          category_id: string
          label: string
          sort_order?: number
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          category_id?: string
          label?: string
          sort_order?: number
          is_active?: boolean
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fields_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "field_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_fields: {
        Row: {
          user_id: string
          field_id: string
          created_at: string
        }
        Insert: {
          user_id: string
          field_id: string
          created_at?: string
        }
        Update: {
          user_id?: string
          field_id?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "profile_fields_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profile_fields_field_id_fkey"
            columns: ["field_id"]
            isOneToOne: false
            referencedRelation: "fields"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_embeddings: {
        Row: {
          user_id: string
          embedding: string | null
          source_hash: string | null
          updated_at: string
        }
        Insert: {
          user_id: string
          embedding?: string | null
          source_hash?: string | null
          updated_at?: string
        }
        Update: {
          user_id?: string
          embedding?: string | null
          source_hash?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "profile_embeddings_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_events: {
        Row: {
          id: string
          user_id: string
          candidate_id: string
          event_type: string
          score: number | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          candidate_id: string
          event_type: string
          score?: number | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          candidate_id?: string
          event_type?: string
          score?: number | null
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_events_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_events_candidate_id_fkey"
            columns: ["candidate_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_config: {
        Row: {
          id: boolean
          weight_shared_fields: number
          weight_category_overlap: number
          weight_semantic: number
          weight_same_major: number
          weight_mutual_friends: number
          weight_same_group: number
          weight_score_closeness: number
          updated_at: string
        }
        Insert: {
          id?: boolean
          weight_shared_fields?: number
          weight_category_overlap?: number
          weight_semantic?: number
          weight_same_major?: number
          weight_mutual_friends?: number
          weight_same_group?: number
          weight_score_closeness?: number
          updated_at?: string
        }
        Update: {
          id?: boolean
          weight_shared_fields?: number
          weight_category_overlap?: number
          weight_semantic?: number
          weight_same_major?: number
          weight_mutual_friends?: number
          weight_same_group?: number
          weight_score_closeness?: number
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      is_chat_participant: {
        Args: { _chat_id: string; _user_id: string }
        Returns: boolean
      }
      set_profile_fields: {
        Args: { p_user_id: string; p_field_ids: string[] }
        Returns: undefined
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
