# frozen_string_literal: true

require 'rails_helper'

describe 'SoftDeletable' do
  with_model :BlogPost do
    # The table block (and an options hash) is passed to Active Record migration’s `create_table`.
    table do |t|
      t.string :title
      t.timestamp :deleted_at
      t.timestamps null: false
    end

    # The model block is the Active Record model’s class body.
    model do
      soft_deletable
      has_many :blog_comments, dependent: :destroy
      has_one :blog_image, dependent: :destroy
      has_many :blog_likes
      validates_presence_of :title
    end
  end

  with_model :BlogComment do
    table do |t|
      t.string :text
      t.belongs_to :blog_post
      t.timestamp :deleted_at
      t.timestamps null: false
    end

    model do
      soft_deletable
      belongs_to :blog_post
    end
  end

  with_model :BlogLike do
    table do |t|
      t.belongs_to :blog_post
      t.timestamp :deleted_at
      t.timestamps null: false
    end

    model do
      soft_deletable
      belongs_to :blog_post
    end
  end

  with_model :BlogImage do
    table do |t|
      t.string :url
      t.belongs_to :blog_post
      t.timestamp :deleted_at
      t.timestamps null: false
    end

    model do
      soft_deletable
      belongs_to :blog_post
      validates_presence_of :url
    end
  end

  it 'can be accessed as a constant' do
    expect(BlogPost).to be
    expect(BlogComment).to be
    expect(BlogLike).to be
    expect(BlogImage).to be
  end

  it 'should be soft deletable' do
    expect(BlogPost.soft_deletable?).to be true
    expect(BlogComment.soft_deletable?).to be true
    expect(BlogLike.soft_deletable?).to be true
    expect(BlogImage.soft_deletable?).to be true
  end

  it 'should not include soft_deletable twice' do
    expect(BlogPost.soft_deletable).to be_nil
    expect(BlogComment.soft_deletable).to be_nil
    expect(BlogLike.soft_deletable).to be_nil
    expect(BlogImage.soft_deletable).to be_nil
  end

  context 'Post with comments and likes' do
    let!(:blog_post) { BlogPost.create(title: 'Blog Post', deleted_at: deleted_at) }
    let!(:first_blog_comment) { BlogComment.create(blog_post: blog_post, text: 'First BlogComment', deleted_at: deleted_at) }
    let!(:second_blog_comment) { BlogComment.create(blog_post: blog_post, text: 'Second BlogComment', deleted_at: deleted_at) }
    let!(:first_blog_like) { BlogLike.create(blog_post: blog_post, deleted_at: deleted_at) }
    let!(:second_blog_like) { BlogLike.create(blog_post: blog_post, deleted_at: deleted_at) }
    let!(:first_blog_image) { BlogImage.create(blog_post: blog_post, url: 'http://image.png', deleted_at: deleted_at) }

    context 'deleted_at is not nil' do
      let!(:deleted_at) { Time.zone.now }

      it 'should ignore deleted' do
        expect(BlogPost.count).to eq(0)
        expect(BlogComment.count).to eq(0)
        expect(BlogLike.count).to eq(0)
        expect(BlogImage.count).to eq(0)
      end

      it 'should return only deleted' do
        expect(BlogPost.only_deleted.count).to eq(1)
        expect(BlogComment.only_deleted.count).to eq(2)
        expect(BlogLike.only_deleted.count).to eq(2)
        expect(BlogImage.only_deleted.count).to eq(1)
        expect(BlogPost.only_deleted.first.blog_comments.count).to eq(0)
        expect(BlogPost.only_deleted.first.blog_likes.count).to eq(0)
        expect(BlogPost.only_deleted.first.blog_comments.only_deleted.count).to eq(2)
        expect(BlogPost.only_deleted.first.blog_likes.only_deleted.count).to eq(2)
      end

      context 'with a BlogPost and BlogComment and BlogLike and BlogImage not deleted' do
        let!(:other_blog_post) { BlogPost.create(title: 'Other Blog Post', deleted_at: nil) }
        let!(:other_blog_comment) { BlogComment.create(blog_post: other_blog_post, text: 'Other BlogComment', deleted_at: nil) }
        let!(:other_blog_like) { BlogLike.create(blog_post: other_blog_post,  deleted_at: nil) }
        let!(:other_blog_image) { BlogImage.create(blog_post: other_blog_post, url: 'https://image.png',  deleted_at: nil) }

        it 'should return all with deleted' do
          expect(BlogPost.with_deleted.count).to eq(2)
          expect(BlogLike.with_deleted.count).to eq(3)
          expect(BlogComment.with_deleted.count).to eq(3)
          expect(BlogImage.with_deleted.count).to eq(2)
        end
      end
    end

    context 'deleted_at is nil' do
      let!(:deleted_at) { nil }

      it 'should ignore deleted' do
        expect(BlogPost.count).to eq(1)
        expect(BlogComment.count).to eq(2)
        expect(BlogLike.count).to eq(2)
        expect(BlogImage.count).to eq(1)
      end

      it 'should not destroy undependent associated records' do
        expect(BlogLike.count).to eq(2)
        expect(blog_post.soft_destroy).to_not be_nil

        expect(blog_post.soft_destroy).to_not be_nil
        expect(BlogLike.count).to eq(2)
        expect(blog_post.blog_likes.count).to eq(2)
      end

      context 'when recursive is true' do
        it 'should destroy the model and destroy the associated records' do
          expect(blog_post.soft_destroy).to be

          expect(blog_post.deleted_at).to_not be_nil
          expect(BlogPost.count).to eq(0)
          expect(BlogComment.count).to eq(0)
          expect(BlogImage.count).to eq(0)
          expect(blog_post.blog_comments.count).to eq(0)
        end

        it 'should restore the model and restore the associated records' do
          expect(BlogPost.count).to eq(1)
          expect(BlogComment.count).to eq(2)
          expect(BlogImage.count).to eq(1)

          expect(blog_post.soft_destroy).to be

          expect(blog_post.deleted_at).to_not be_nil
          expect(BlogPost.count).to eq(0)
          expect(BlogComment.count).to eq(0)
          expect(BlogImage.count).to eq(0)

          expect(blog_post.soft_restore).to_not be_nil

          expect(blog_post.deleted_at).to be_nil
          expect(BlogPost.count).to eq(1)
          expect(BlogComment.count).to eq(2)
          expect(BlogImage.count).to eq(1)
          expect(blog_post.blog_comments.count).to eq(2)
          expect(blog_post.blog_image).to be
        end
      end

      context 'when recursive is false' do
        it 'should destroy the model and not destroy the associated records' do
          expect(blog_post.soft_destroy(recursive: false)).to be

          expect(blog_post.deleted_at).to_not be_nil
          expect(BlogPost.count).to eq(0)
          expect(BlogComment.count).to eq(2)
          expect(BlogImage.count).to eq(1)
        end

        it 'should restore the model and not restore the associated records' do
          expect(blog_post.soft_destroy(recursive: true)).to be

          expect(blog_post.deleted_at).to_not be_nil
          expect(blog_post.blog_comments.count).to eq(0)
          expect(blog_post.blog_image.deleted_at).to_not be_nil
          expect(blog_post.reload.blog_image).to be_nil

          expect(BlogPost.count).to eq(0)
          expect(BlogComment.count).to eq(0)
          expect(BlogImage.count).to eq(0)

          expect(blog_post.soft_restore(recursive: false)).to_not be_nil

          expect(blog_post.deleted_at).to be_nil
          expect(blog_post.blog_comments.count).to eq(0)
          expect(blog_post.reload.blog_image).to be_nil

          expect(BlogPost.count).to eq(1)
          expect(BlogComment.count).to eq(0)
          expect(BlogImage.count).to eq(0)
        end
      end
    end
  end
end
