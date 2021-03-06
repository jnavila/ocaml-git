(*
 * Copyright (c) 2013-2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** Pack indexes. *)

type t
(** Abstract type of pack index. *)

type f = Hash.t -> int option
(** The type of functions associating Hash1 keys to offset in the pack
    file. *)

type raw = {
  offsets      : int Hash.Map.t;
  crcs         : int32 Hash.Map.t;
  pack_checksum: Hash.t;
}
(** [offsests] is the positions of the Hash objects in the
    corresponding raw pack file.

    [crcs] contains the CRC-32 value of the packed object data.

    [pack_checksum] is the corresponding pack file checksums, value
    which is needed when writing the pack index file to disk. *)

module Raw: sig

  include Object.S with type t = raw

  val keys: t -> Hash.Set.t
  (** Read only the keys contained in the index. *)

  val find_offset: t -> Hash.t -> int option
  (** Same as {!find_offset} but for raw packs. *)

  val lengths: t -> int option Hash.Map.t
  (** [lengths] returns the difference between two consecutive offsets
      (appart for the last elements, where the lenght can be [None] is
      the index file is build from a raw pack file). *)

end

module Make (D: Hash.DIGEST): sig

  val input: ?cache_size:int -> Cstruct.buffer -> t
  (** Create a pack index object. The results of [find_offset] are
      cached for upto [cache_size] Hash objects *)

  val find_offset: t -> Hash.t -> int option
  (** [find_offset] searches the index for the offset of the Hash object.
      Binary search is performed until the candidates are narrowed down to
      [scan_thresh] or less. *)

  val mem: t -> Hash.t -> bool
  (** [mem] checks if the Hash object is contained in the index object *)

  val keys: t -> Hash.t list
  (** [keys t] is the list of hash keys present in [t]. *)

  module Raw: Object.IO with type t = raw

end
