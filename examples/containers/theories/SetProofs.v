Require Import GHC.Base.
Import GHC.Base.Notations.
Require Import Proofs.GHC.Base.
Require Import Data.Set.Internal.
Import GHC.Num.Notations.
Require Import OrdTactic.
Require Import Psatz.
Set Bullet Behavior "Strict Subproofs".


Ltac destruct_ptrEq := lazymatch goal with
  | |- context [if PtrEquality.ptrEq ?x ?y && PtrEquality.ptrEq ?x2 ?y2 then _ else _]
  => let Hpe := fresh "Hpe" in
     let Hpe1 := fresh "Hpe1" in
     let Hpe2 := fresh "Hpe2" in
     destruct (PtrEquality.ptrEq x y && PtrEquality.ptrEq x2 y2) eqn:Hpe;
     [ rewrite andb_true_iff in Hpe;
       destruct Hpe as [Hpe1 Hpe2];
       apply PtrEquality.ptrEq_eq in Hpe1;
       apply PtrEquality.ptrEq_eq in Hpe2;
       subst
     | clear Hpe]
  | |- context [if PtrEquality.ptrEq ?x ?y then _ else _]
  => let Hpe := fresh "Hpe" in
     destruct (PtrEquality.ptrEq x y) eqn:Hpe;
     [ apply PtrEquality.ptrEq_eq in Hpe; subst
     | clear Hpe] 
end.


Section WF.
Context {e : Type} {HEq : Eq_ e} {HOrd : Ord e} {HEqLaws : EqLaws e}  {HOrdLaws : OrdLaws e}.

Lemma compare_Eq : forall (x y : e),
  compare x y = Eq <-> x == y = true.
Proof. intuition; order e. Qed.
Lemma compare_Lt : forall (x y : e),
  compare x y = Lt <-> x < y = true.
Proof. intuition; order e. Qed.
Lemma compare_Gt : forall (x y : e),
  compare x y = Gt <-> x > y = true.
Proof. intuition; order e. Qed.

Lemma lt_eq_r : forall x y z,
  x < y = true ->
  z == y = true ->
  x < z = true.
Proof. intuition; order e. Qed.

Lemma lt_eq_l : forall x y z,
  x < y = true ->
  z == x = true ->
  z < y = true.
Proof. intuition; order e. Qed.

Lemma lt_not_eq : forall (x y : e),
  x < y = true -> x == y = false.
Proof. intuition; order e. Qed.

Lemma gt_not_eq : forall (x y : e),
 x > y = true -> x == y = false.
Proof. intuition; order e. Qed.


Lemma lt_gt : forall (x y : e), (x > y) = (y < x).
Proof. intros. rewrite eq_iff_eq_true. intuition; order e. Qed.

Lemma lt_trans : forall (x y z : e),
  x < y = true -> y < z = true -> x < z = true.
Proof. intuition; order e. Qed.


(** This is just like size, but with a type signature that does not confuse [lia] *)
Definition size (s : Set_ e) : Z :=
  match s with | Bin sz _ _ _ => sz
               | Tip => 0 end.

Lemma size_size: Internal.size = size.
Proof. reflexivity. Qed.

(* Bounds may be absent (infinity) *)
Definition bound := (option e)%type.

(** A suitable comparision operator for bounds.
   If someone feels like it, then you may introduce nice notation. *)
Definition isLB : bound -> e -> bool :=
  fun lb e => match lb with
    | Some lb => lb < e
    | None => true
  end.

Definition isUB : bound -> e -> bool :=
  fun ub e => match ub with
    | Some ub => e < ub
    | None => true
  end.

Ltac order_Bounds :=
  intros;
  simpl isUB in *;
  simpl isLB in *;
  repeat (congruence || lazymatch goal with
    | H : isUB ?ub _ = false |- _ => destruct ub; simpl isUB in *
    | |-  isUB ?ub _ = _          => destruct ub; simpl isUB in *
    | H : isLB ?lb _ = false |- _ => destruct lb; simpl isLB in *
    | |-  isLB ?lb _ = _          => destruct lb; simpl isLB in *
   end);
   order e.

Lemma isLB_lt:
  forall lb x y,
  isLB lb x = true->
  x < y = true ->
  isLB lb y = true.
Proof. order_Bounds. Qed.

Lemma isUB_lt:
  forall ub x y,
  isUB ub x = true->
  y < x = true ->
  isUB ub y = true.
Proof. order_Bounds. Qed.

(** The balancing property of a binary node *)
Definition balance_prop sz1 sz2 :=
  (sz1 + sz2 <= 1 \/ sz1 <= delta * sz2 /\ sz2 <= delta * sz1)%Z.

(** One precondition for [balanceL]: The left tree has been inserted to (but not by too much).
    This is mechanically derived from the context in the call to [balanceL] in [link], and
    unfortunately not very educational.
 *)
Definition balance_prop_inserted sz1 sz2 :=
  (delta * sz1 <= delta*delta*sz2 + delta*sz2 + sz2 /\ sz2 <= sz1)%Z.

(* NB: this does not work: 
Definition balance_prop_inserted sz1 sz2 := balance_prop sz1 sz2.
*)

Fixpoint sem (s : Set_ e) (i : e) : bool :=
  match s with | Bin _ x s1 s2 => sem s1 i || (i == x) || sem s2 i
               | Tip => false end.

Lemma sem_resp_eq : forall s i j,
  i == j = true -> sem s i = sem s j.
Proof.
  intros.
  induction s.
  * simpl.
    rewrite IHs1, IHs2.
    replace (j == a) with (i == a) by (apply eq_true_iff_eq; split; order e).
    reflexivity.
  * reflexivity.
Qed.

(** This inductive predicate describes when sets are well-formed within 
  (exclusive) bounds.
*)


Inductive Bounded : Set_ e -> bound -> bound -> Prop :=
  | BoundedTip : forall lb ub,
    Bounded Tip lb ub
  | BoundedBin :
    forall lb ub,
    forall s1,
    forall s2,
    forall x sz,
    Bounded s1 lb (Some x) ->
    Bounded s2 (Some x) ub ->
    isLB lb x = true ->
    isUB ub x = true ->
    sz = (1 + size s1 + size s2)%Z ->
    balance_prop (size s1) (size s2) ->
    Bounded (Bin sz x s1 s2) lb ub.

(** There are no values outside the bounds *)
Lemma sem_outside_below:
  forall {s lb ub i},
  Bounded s lb ub ->
  isLB lb i = false ->
  sem s i = false.
Proof.
  intros ???? HD ?.
  induction HD; intros; subst; simpl in *; intuition.
  rewrite H2.
  rewrite IHHD2 by order_Bounds.
  rewrite orb_false_l. rewrite orb_false_r. order_Bounds.
Qed.

Lemma sem_outside_above:
  forall {s lb ub i},
  Bounded s lb ub ->
  isUB ub i = false ->
  sem s i = false.
Proof.
  intros ???? HD ?.
  induction HD; intros; subst; simpl in *; intuition.
  rewrite H2.
  rewrite IHHD1 by order_Bounds.
  rewrite orb_false_l. rewrite orb_false_r. order_Bounds.
Qed.

Lemma sem_inside:
  forall {s lb ub i},
  Bounded s lb ub ->
  sem s i = true ->
  isLB lb i = true /\ isUB ub i = true.
Proof.
  intros ???? HD ?.
  induction HD; intros; subst; simpl in *; rewrite ?orb_true_iff in *; intuition;
  order_Bounds.  
Qed.


(* We use this as a rewrite rule because
   [simpl (size (Bin _ _ _ _ ))]
   simplifies the [ 1 + _ ] which is annoying. *)
Lemma size_Bin: forall sz x (s1 s2 : Set_ e),
  size (Bin sz x s1 s2) = sz.
Proof. intros. reflexivity. Qed.

(* Pose the proof [prf], unless it already exists. *)
Ltac pose_new prf :=
  let prop := type of prf in
  match goal with 
    | [ H : prop |- _] => fail 1
    | _ => pose proof prf
  end.

(* Pose the [prop], using [prf], unless it already exists. *)
Ltac assert_new prop prf :=
  match goal with 
    | [ H : prop |- _] => fail 1
    | _ => assert prop by prf
  end.

Lemma size_nonneg:
  forall {s lb ub},
  Bounded s lb ub -> (0 <= size s)%Z.
Proof.
  intros ??? HD.
  induction HD.
  * simpl. lia.
  * simpl. lia.
Qed.


Ltac postive_sizes :=
  repeat match goal with [ H : Bounded ?s _ _ |- _ ] => pose_new (size_nonneg H) end.

Lemma size_0_iff_tip:
  forall {s lb ub},
  Bounded s lb ub -> (size s = 0)%Z <-> s = Tip.
Proof.
  induction 1.
  * intuition.
  * postive_sizes;
    rewrite ?size_Bin in *.
    intuition try (congruence || lia).
Qed.

Lemma Bounded_change_ub:
  forall s lb ub ub',
  Bounded s lb (Some ub) ->
  ub <= ub' = true ->
  Bounded s lb (Some ub').
Proof.
  intros ???? HD Heq.
  remember (Some ub) as ubo.
  induction HD; subst.
  * apply BoundedTip; auto.
  * intuition.
    eapply BoundedBin; try eassumption; try reflexivity.
    simpl in *.
    order_Bounds.
Qed.

Lemma Bounded_change_lb:
  forall s lb lb' ub,
  Bounded s (Some lb) ub ->
  lb' <= lb = true ->
  Bounded s (Some lb') ub.
Proof.
  intros ???? HD Heq.
  remember (Some lb) as lbo.
  induction HD; subst.
  * apply BoundedTip; reflexivity.
  * intuition.
    eapply BoundedBin; try eassumption; try reflexivity.
    order_Bounds.
Qed.

(* Bounded_change_ub and Bounded_relax_ub could be united with
   a isNonStrictUB predicate *)
Lemma Bounded_relax_ub:
  forall s lb ub ub',
  Bounded s lb (Some ub) ->
  isUB ub' ub = true ->
  Bounded s lb ub'.
Proof.
  intros ???? HD Heq.
  remember (Some ub) as ubo.
  induction HD; subst.
  * apply BoundedTip; auto.
  * intuition.
    eapply BoundedBin; try eassumption; try reflexivity.
    simpl in *.
    order_Bounds.
Qed.

Lemma Bounded_relax_lb:
  forall s lb lb' ub,
  Bounded s (Some lb) ub ->
  isLB lb' lb = true ->
  Bounded s lb' ub.
Proof.
  intros ???? HD Heq.
  remember (Some lb) as lbo.
  induction HD; subst.
  * apply BoundedTip; reflexivity.
  * intuition.
    eapply BoundedBin; try eassumption; try reflexivity.
    order_Bounds.
Qed.

Lemma Bounded_relax_ub_None:
  forall s lb ub,
  Bounded s lb ub ->
  Bounded s lb None.
Proof.
  intros ??? HD.
  induction HD; subst.
  * apply BoundedTip; reflexivity.
  * eapply BoundedBin; try eassumption; try reflexivity.
Qed.

Lemma Bounded_relax_lb_None:
  forall s lb ub,
  Bounded s lb ub ->
  Bounded s None ub.
Proof.
  intros ??? HD.
  induction HD; subst.
  * apply BoundedTip; reflexivity.
  * eapply BoundedBin; try eassumption; try reflexivity.
Qed.

(** Learns bounds of values found in some set in the context *)
Ltac inside_bounds :=
  repeat lazymatch goal with
    | H : Bounded ?s _ _, H2 : sem ?s ?i = true |- _ =>
       apply (sem_inside H) in H2; destruct H2
  end.

(** Solve [isLB] and [isUB] goals.  *)
Ltac solve_Bounds := first
  [ eassumption
  | solve [inside_bounds; order_Bounds]
  | idtac "solve_Bounds gave up"
  ].

(* Solve equations of the form
     forall i, f i = f0 i || f1 i
   possibly using equations from the context.
   Fails if it does not start with [forall i,], but may leave a partially solve goal.
    *)
Ltac f_solver_simple  :=
  let i := fresh "i" in 
  intro i;
  try reflexivity; (* for when we have an existential variable *)
  repeat multimatch goal with [ H : (forall i, _) |- _] => specialize (H i) end;
  repeat match goal with [ H : ?f = _ |- context [?f i] ] => rewrite H in *; clear H end;
  simpl sem; rewrite ?orb_assoc, ?orb_false_r, ?orb_false_l;
  try reflexivity.


(** This auxillary tactic destructs one boolean atom in the argument *)

Ltac split_bool_go expr :=
  lazymatch expr with 
    | true       => fail
    | false      => fail
    | Some _     => fail
    | None       => fail
    | match ?x with _ => _ end => split_bool_go x || (simpl x; cbv match)
    | negb ?x    => split_bool_go x
    | ?x && ?y   => split_bool_go x || split_bool_go y
    | ?x || ?y   => split_bool_go x || split_bool_go y
    | xorb ?x ?y => split_bool_go x || split_bool_go y
    | ?bexpr     => destruct bexpr eqn:?
  end.

(** This auxillary tactic destructs one boolean or option atom in the goal *)


Ltac split_bool :=
  match goal with 
    | |- ?lhs = ?rhs        => split_bool_go lhs || split_bool_go rhs
    (* A bit ad-hoc, could be improved: *)
    | H : ?x || ?y = true  |- _ => split_bool_go x
    | H : ?x || ?y = false |- _ => split_bool_go x
    | H : ?x && ?y = true  |- _ => split_bool_go x
    | H : ?x && ?y = false |- _ => split_bool_go x
  end.


Ltac f_solver_cleanup :=
  simpl negb in *;
  rewrite ?andb_true_r, ?andb_true_l, ?andb_false_r, ?andb_false_l,
          ?orb_true_r, ?orb_true_l, ?orb_false_r, ?orb_false_l,
          ?orb_assoc, ?and_assoc in *;
  try congruence;
  repeat lazymatch goal with
    |  H1 : true = true |- _ => clear H1
    |  H1 : true = _    |- _ => symmetry in H1
    |  H1 : false = false |- _ => clear H1
    |  H1 : false = _    |- _ => symmetry in H1
  end;
  try solve [exfalso; inside_bounds; order_Bounds];
  try reflexivity;
  try lazymatch goal with
    |  H1 : (?i == ?j) = true , H2 : sem ?s ?i = true, H3 : sem ?s ?j = false |- _
      => exfalso; rewrite (sem_resp_eq s i j H1) in H2; congruence
    |  H1 : (?i == ?j) = true , H2 : sem ?s ?i = false, H3 : sem ?s ?j = true |- _
      => exfalso; rewrite (sem_resp_eq s i j H1) in H2; congruence
  end.

Ltac f_solver_step := first
  [ split_bool
  | lazymatch goal with H : context [if ?x == ?y then _ else _] |- _
      => destruct (x == y) eqn:?
    end
  | exfalso
  ].

Ltac f_solver := f_solver_simple; repeat (f_solver_cleanup; f_solver_step).

(** A variant of [lia] that unfolds a few specific things and knows that
   the size of a well-formed tree is positive. *)
Ltac lia_sizes :=
  postive_sizes;
  unfold balance_prop_inserted, balance_prop, delta, ratio in *;
  unfold fromInteger, op_zg__, op_zl__, op_zt__, op_zp__,
                      Num_Integer__, Ord_Integer___,
                      op_zg____, op_zl____ in *;
  rewrite ?size_size in *;
  rewrite ?size_Bin in *; simpl (size Tip) in *;
  lia.

(** A tactic to solve questions about size. *)
Ltac solve_size := first
  [ assumption
  | reflexivity
  | lia_sizes
  | idtac "solve_size gave up"
  ].

(** Solve goals of Bounded. Should be back-tracking free, I think. *)
Ltac solve_Bounded := eassumption || lazymatch goal with
  | [ |- Bounded Tip _ _ ]
    => apply BoundedTip
  | [ H : Bounded ?s ?lb (Some ?ub) |- Bounded ?s ?lb (Some ?ub') ]
    => apply (Bounded_change_ub _ _ _ _ H); solve_Bounds
  | [ H : Bounded ?s (Some ?lb) ?ub  |- Bounded ?s (Some ?lb') ?ub ]
    => apply (Bounded_change_lb _ _ _ _ H); solve_Bounds
  | [ H : Bounded ?s ?lb (Some ?ub) |- Bounded ?s ?lb ?ub' ]
    => apply (Bounded_relax_ub _ _ _ _ H); solve_Bounds
  | [ H : Bounded ?s (Some ?lb) ?ub  |- Bounded ?s ?lb' ?ub ]
    => apply (Bounded_relax_lb _ _ _ _ H); solve_Bounds
  | [ |- Bounded (Bin _ _ _ _) _ _ ]
    => apply BoundedBin;
        [ solve_Bounded
        | solve_Bounded
        | solve_Bounds
        | solve_Bounds
        | solve_size
        | solve_size
        ]
  | |- ?H => fail "solve_Bounded gave up on" H
  end.

(** We now have special tactics for the three kinds of preconditions most
    our lemmas below have. So we can write a tactic that correctly chooses the
    right tactic.
    Why not simply use [first [solve_Bounded|solve_Bounds|solve_size]]?
    Because that would involve backtracking which hides error messages from us,
    and is possibly too slow.
  *)

Ltac solve_Precondition := lazymatch goal with
  | |- Bounded _ _ _          => solve_Bounded
  | |- isLB _ _ = true        => solve_Bounds
  | |- isUB _ _ = true        => solve_Bounds
  | |- context [set_size]     => simpl; lia    (* in well-founded recursion *)
  | |- _ = _                  => solve_size
  | |- context [balance_prop] => solve_size
  | |- ?H                     => fail "solve_Precondition does not recognize this goal: " H
  end.


(** A proposition of the form [Desc s lb ub sz f] tells us
  everything we need to know about [s].

  Therefore, it is phrased as an induction lemma which replaces
  the concrete Set (e.g. [insert y s]) with a fresh variable [s'],
  and adds all interesting bits about it to the context.

  To prove a [Desc] statement, use [apply showDesc].

  To use a [Desc] statement, use [applyDesc HD] or [apply foo_Desc].
  *)

Definition Desc s lb ub sz f : Prop :=
  forall (P : Set_ e -> Prop),
  (forall s,
    Bounded s lb ub ->
    size s = sz ->
    sem s = f ->
    P s) ->
  P s.

Local Inductive HIDE (P : Prop) := unhide : P -> HIDE P.
Local Lemma hide : forall {P : Prop},  HIDE P -> P. Proof. intros. inversion H. assumption. Qed.

Ltac applyDesc lem :=
  apply hide;
  eapply lem;
  [ solve_Precondition ..
  | let s := fresh "s" in 
    let HB := fresh "HB" in
    let Hsz := fresh "Hsz" in
    let Hsem := fresh "Hsem" in
    intros s HB Hsz Hsem;
    apply unhide;
    try replace (size s) in *;
    try replace (sem s) in *;
    try assumption
  ].

Require Import Coq.Logic.PropExtensionality.
Require Import Coq.Logic.FunctionalExtensionality.
Lemma showDesc :
  forall s lb ub sz f,
  Bounded s lb ub /\ size s = sz /\ (forall i, sem s i = f i) ->
  Desc s lb ub sz f.
Proof.
  intros. intros P HP.
  enough (Bounded s lb ub  /\ size s = sz /\ sem s = f ) by intuition.
  destruct H as [HB [Hsz Hf]].
  rewrite Hsz.
  replace (sem s) with f by (symmetry; extensionality i; apply Hf).
  replace (Bounded s lb ub) with True by (apply propositional_extensionality; tauto).
  intuition.
Qed.

Lemma Desc_change_f:
  forall s lb ub sz f f',
  (forall i, f' i = f i) ->
  Desc s lb ub sz f' <-> Desc s lb ub sz f.
Proof.
  intros.
  split; intro HD; applyDesc HD;
  (apply showDesc; split; [solve_Bounded | split; [solve_size | simpl sem; try solve [f_solver]]]);
  intuition.
Qed.

(** A variant that does not indicate anything about [size]. *)

Definition Desc' s lb ub f : Prop :=
  forall (P : Set_ e -> Prop),
  (forall s,
    Bounded s lb ub ->
    True ->             (* So that we can still use [applyDesc] here *)
    sem s = f ->
    P s) ->
  P s.

Lemma showDesc' :
  forall s lb ub f,
  Bounded s lb ub /\ (forall i, sem s i = f i) ->
  Desc' s lb ub f.
Proof.
  intros. intros P HP.
  enough (Bounded s lb ub /\ sem s = f ) by intuition.
  destruct H as [HB Hf].
  replace (sem s) with f by (symmetry; extensionality i; apply Hf).
  replace (Bounded s lb ub) with True by (apply propositional_extensionality; tauto).
  intuition.
Qed.

Ltac solve_Desc :=
 lazymatch goal with
 | |- (Desc _ _ _ _ _)
 => apply showDesc; split; [solve_Bounded | split; [solve_size | simpl sem; try solve [f_solver]]]
 | |- (Desc' _ _ _ _)
 => apply showDesc'; split; [solve_Bounded | simpl sem; try solve [f_solver]]
 | |- ?P
 => fail "solve_Desc: Goal not a Desc or Desc' proposition: " P
 end.


(** And any set that has a bounds is well-formed *)
Definition WF (s : Set_ e) : Prop := Bounded s None None.

Lemma Desc_WF:
  forall s sz f,
  Desc s None None sz f -> WF s.
Proof.
  intros ??? HD.
  unfold WF.
  (* Unfortunately, [apply HD] does not work unless we have [size s] and [sem s]
     in the context. *)
  assert (Bounded s None None /\ size s = size s /\ sem s = sem s) by (apply HD; auto).
  intuition.
Qed.


(** For every set in the context, try to see if [lia] knows it is empty. *)
Ltac find_Tip :=
  match goal with [ H : Bounded ?s _ _ |- _ ] =>
    assert_new (size s = 0)%Z lia_sizes;
    rewrite (size_0_iff_tip H) in *;
    subst s;
    inversion H;
    clear H;
    subst
  end.

Require Import Coq.Program.Tactics.

Open Scope Z_scope.

(** ** Verification of [empty] *)

Lemma empty_Desc:
  forall lb ub,
  Desc empty lb ub 0 (fun _ => false).
Proof. intros. unfold empty. solve_Desc. Qed.

Lemma empty_WF: WF empty.
Proof. intros. unfold empty. eapply Desc_WF. apply empty_Desc. Qed.


(** ** Verification of [null] *)

Lemma null_spec:
  forall s, WF s -> null s = true <-> s = Tip.
Proof. intros. unfold null. inversion H; simpl; intuition (congruence || lia_sizes). Qed.


(* verification of singleton *)

Lemma singleton_Desc:
  forall x lb ub,
  isLB lb x = true ->
  isUB ub x = true ->
  Desc (singleton x) lb ub 1 (fun i => i == x).
Proof.
  intros.

  unfold singleton.
  unfold fromInteger, Num_Integer__.
  solve_Desc.
Qed.


Lemma singleton_WF:
  forall y, WF (singleton y).
Proof. intros. eapply Desc_WF. eapply singleton_Desc; reflexivity. Qed.

(** ** Verifying the various balancing operations *)

Lemma balanceL_Desc:
    forall x s1 s2 lb ub,
    Bounded s1 lb (Some x) ->
    Bounded s2 (Some x) ub  ->
    isLB lb x = true ->
    isUB ub x = true->
    balance_prop (size s1) (size s2) \/
    balance_prop_inserted (size s1 - 1) (size s2) /\ (1 <= size s1)%Z \/
    balance_prop (size s1) (size s2 + 1) ->
    Desc (balanceL x s1 s2) lb ub (1 + size s1 + size s2) (fun i => sem s1 i || (i == x) || sem s2 i).
Proof.
  intros.

  unfold balanceL.
  unfold op_zg__, op_zl__, Ord_Integer___, op_zg____, op_zl____.

  repeat lazymatch goal with [ H : Bounded ?s _ _ |- context [match ?s with _ => _ end] ] => inversion H; subst; clear H end;
  repeat lazymatch goal with [ |- context [if (?x <? ?y)%Z then _ else _] ] => destruct (Z.ltb_spec x y) end;
  rewrite ?size_Bin in *; simpl (size Tip) in *; simpl sem;
  simpl isLB in *;
  simpl isUB in *.
  all: try solve [exfalso; lia_sizes]. (* Some are simply impossible *)
  all: repeat find_Tip.
  all: try solve [solve_Desc].
Qed.

Lemma balanceR_Desc:
    forall x s1 s2 lb ub,
    Bounded s1 lb (Some x) ->
    Bounded s2 (Some x) ub ->
    isLB lb x = true ->
    isUB ub x = true->
    balance_prop (size s1) (size s2) \/
    balance_prop_inserted (size s2 - 1) (size s1) /\ (1 <= size s2)%Z  \/
    balance_prop (size s1 + 1) (size s2) ->
    Desc (balanceR x s1 s2) lb ub (1 + size s1 + size s2) (fun i => sem s1 i || (i == x) || sem s2 i).
Proof.
  intros.

  unfold balanceR.
  unfold op_zg__, op_zl__, Ord_Integer___, op_zg____, op_zl____.

  repeat lazymatch goal with [ H : Bounded ?s _ _ |- context [match ?s with _ => _ end] ] => inversion H; subst; clear H end;
  repeat lazymatch goal with [ |- context [if (?x <? ?y)%Z then _ else _] ] => destruct (Z.ltb_spec x y) end;
  rewrite ?size_Bin in *; simpl (size Tip) in *; simpl sem;
  simpl isLB in *;
  simpl isUB in *.
  all: try solve [exfalso; lia_sizes]. (* Some are simply impossible *)
  all: repeat find_Tip.
  all: try solve [solve_Desc].
Qed.


Lemma insertMax_Desc:
    forall x s1 lb ub,
    Bounded s1 lb (Some x) ->
    isLB lb x = true ->
    isUB ub x = true->
    Desc (insertMax x s1) lb ub (1 + size s1) (fun i => sem s1 i || (i == x)).
Proof.
  intros.
  
  remember (Some x) as ub'. revert dependent x.
  induction H; intros; subst; cbn - [Z.add].
  * applyDesc singleton_Desc.
    solve_Desc.
  * clear IHBounded1.
    applyDesc IHBounded2.
    applyDesc balanceR_Desc.
    solve_Desc.
Qed.

Lemma insertMin_Desc:
    forall x s2 lb ub,
    Bounded s2 (Some x) ub ->
    isLB lb x = true ->
    isUB ub x = true->
    Desc (insertMin x s2) lb ub (1 + size s2) (fun i => (i == x) || sem s2 i).
Proof.
  intros.
  remember (Some x) as ub'. revert dependent x.
  induction H; intros; subst; cbn - [Z.add].
  * applyDesc singleton_Desc.
    solve_Desc.
  * clear IHBounded2.
    applyDesc IHBounded1.
    applyDesc balanceL_Desc.
    solve_Desc.
Qed.

Lemma link_eq (x : e) (s1: Set_ e)  (s2: Set_ e) :
  link x s1 s2 =
       match s1, s2 with
          | Tip , r => insertMin x r
          | l , Tip => insertMax x l
          | (Bin sizeL y ly ry as l) , (Bin sizeR z lz rz as r) =>
            if Sumbool.sumbool_of_bool ((delta GHC.Num.* sizeL) GHC.Base.< sizeR)
            then balanceL z (link x l lz) rz
            else if Sumbool.sumbool_of_bool  ((delta GHC.Num.* sizeR) GHC.Base.< sizeL)
                 then balanceR y ly (link x ry r)
                 else bin x l r
        end.
Proof.
  unfold link at 1, link_func at 1.
  destruct s1; only 2: reflexivity.
  destruct s2; only 2: reflexivity.
  lazymatch goal with 
    |- Wf.Fix_sub ?A ?R ?Rwf ?P ?F_sub ?x = ?rhs => 
    apply (@Wf.WfExtensionality.fix_sub_eq_ext A R Rwf P F_sub x)
  end.
Qed.

(* [program_simpl] calls [simpl], which is very confusing due to [1 + _]. So
ask [Next Obligation] to use this only when it solves the goal completely. *)
Local Obligation Tactic := try solve [program_simpl].

Program Fixpoint link_Desc (x : e) (s1: Set_ e)  (s2: Set_ e)
  {measure (set_size s1 + set_size s2)} :
    forall lb ub,
    Bounded s1 lb (Some x) ->
    Bounded s2 (Some x) ub  ->
    isLB lb x = true ->
    isUB ub x = true->
    Desc (link x s1 s2) lb ub (1 + size s1 + size s2) (fun i => sem s1 i || (i == x) || sem s2 i)
    := _.
Next Obligation.
  intros.
  rewrite link_eq. 
  inversion H; subst; clear H;
  inversion H0; subst; clear H0.
  * simpl insertMin.
    applyDesc singleton_Desc.
    solve_Desc.
  * applyDesc insertMin_Desc.
    solve_Desc.
  * applyDesc insertMax_Desc.
    solve_Desc.
  * destruct (Sumbool.sumbool_of_bool _);
    only 2: destruct (Sumbool.sumbool_of_bool _);
    rewrite ?Z.ltb_lt, ?Z.ltb_ge in *.
    - applyDesc link_Desc.
      applyDesc balanceL_Desc.
      solve_Desc.
    - applyDesc link_Desc.
      applyDesc balanceR_Desc.
      solve_Desc.
    - clear link_Desc.
      unfold bin.
      solve_Desc.
Qed.

(* verification of member *)

Lemma member_spec:
 forall {s lb ub i}, Bounded s lb ub -> member i s = sem s i.
Proof.
  intros ???? HB.
  induction HB.
  * simpl. reflexivity.
  * subst; simpl.
    destruct (compare i x) eqn:?.
    + replace (i == x) with true by order_Bounds.
      rewrite orb_true_r.
      reflexivity.
    + replace (i == x) with false by order_Bounds.
      rewrite IHHB1.
      rewrite (sem_outside_below HB2) by order_Bounds.
      rewrite !orb_false_r.
      reflexivity.
    + replace (i == x) with false by order_Bounds.
      rewrite IHHB2.
      rewrite (sem_outside_above HB1) by order_Bounds.
      rewrite orb_false_l.
      reflexivity.
Qed.


(** ** verification of [insert] *)

(* The [orig] passing and the local fixpoint in insert is plain ugly, so let’s to this instead *)

Fixpoint insert' (x : e) (s : Set_ e ) : Set_ e :=
  match s with 
    | Tip => singleton x
    | Bin sz y l r => match compare x y with
      | Lt =>
        let l' := insert' x l in
        if PtrEquality.ptrEq l' l then s else balanceL y l' r
      | Gt =>
        let r' := insert' x r in 
        if PtrEquality.ptrEq r' r then s else balanceR y l r'
      | Eq =>
        if PtrEquality.ptrEq x y then s else Bin sz x l r
     end
  end.

Lemma insert_insert' : forall x s, insert x s = insert' x s.
Proof.
  intros.
  unfold insert.
  induction s; simpl.
  * destruct (compare x a).
    - reflexivity.
    - rewrite IHs1. reflexivity.
    - rewrite IHs2. reflexivity.
  * reflexivity.
Qed.
Lemma insert_Desc:
  forall y s lb ub,
  Bounded s lb ub ->
  isLB lb y = true ->
  isUB ub y = true ->
  Desc (insert y s) lb ub (if sem s y then size s else (1 + size s)%Z) (fun i => (i == y) || sem s i).
Proof.
  intros ???? HB HLB HUB.

  rewrite insert_insert'.
  induction HB; intros.
  * simpl.
    applyDesc singleton_Desc; try eassumption; solve_Desc.
  * subst; cbn -[Z.add].
    destruct (compare y x) eqn:?.
    + rewrite compare_Eq in *.
      rewrite Heqc.
      rewrite ?orb_true_r, ?orb_true_l.
      destruct_ptrEq.
      - solve_Desc.
      - unfold Datatypes.id.
        solve_Desc.
    + clear IHHB2.
      applyDesc IHHB1.

      rewrite (sem_outside_below HB2) by order_Bounds.
      replace (y == x) with false by order_Bounds.
      rewrite ?orb_false_r, ?orb_false_l.

      destruct_ptrEq.
      - replace (sem s1 y) with true
           by (destruct (sem s1 y) eqn:?; auto; exfalso; lia).
        solve_Desc.
      - destruct (sem s1 y);
        applyDesc balanceL_Desc;
        solve_Desc.
    + (* more or less a copy-n-paste from above *)
      clear IHHB1.
      applyDesc IHHB2.

      rewrite (sem_outside_above HB1) by order_Bounds.
      replace (y == x) with false by order_Bounds.
      rewrite ?orb_false_r, ?orb_false_l.

      destruct_ptrEq.
      - replace (sem s2 y) with true
           by (destruct (sem s2 y) eqn:?; auto; exfalso; lia).
        solve_Desc.
      - destruct (sem s2 y);
        applyDesc balanceR_Desc;
        solve_Desc.
Qed.

(** For our purposes, [insertR] and [insert] are equivalent (the sets 
    are equal up to [==] of elements. *)

Fixpoint insertR' (x : e) (s : Set_ e ) : Set_ e :=
  match s with 
    | Tip => singleton x
    | Bin sz y l r => match compare x y with
      | Lt =>
        let l' := insertR' x l in
        if PtrEquality.ptrEq l' l then s else balanceL y l' r
      | Gt =>
        let r' := insertR' x r in 
        if PtrEquality.ptrEq r' r then s else balanceR y l r'
      | Eq => Bin sz y l r
     end
  end.

Lemma insertR_insertR' : forall x s, insertR x s = insertR' x s.
Proof.
  intros.
  unfold insertR.
  induction s; simpl.
  * destruct (compare x a).
    - reflexivity.
    - rewrite IHs1. reflexivity.
    - rewrite IHs2. reflexivity.
  * reflexivity.
Qed.


Lemma insertR_Desc:
  forall y s lb ub,
  Bounded s lb ub ->
  isLB lb y = true ->
  isUB ub y = true ->
  Desc (insertR y s) lb ub (if sem s y then size s else (1 + size s)%Z) (fun i => (i == y) || sem s i).
Proof.
  intros ???? HB HLB HUB.

  rewrite insertR_insertR'.
  induction HB; intros.
  * simpl.
    applyDesc singleton_Desc; try eassumption; solve_Desc.
  * subst; cbn -[Z.add].
    destruct (compare y x) eqn:?.
    + rewrite compare_Eq in *.
      rewrite Heqc.
      rewrite ?orb_true_r, ?orb_true_l.
      solve_Desc.
    + clear IHHB2.
      applyDesc IHHB1.

      rewrite (sem_outside_below HB2) by order_Bounds.
      replace (y == x) with false by order_Bounds.
      rewrite ?orb_false_r, ?orb_false_l.

      destruct_ptrEq.
      - replace (sem s1 y) with true
           by (destruct (sem s1 y) eqn:?; auto; exfalso; lia).
        solve_Desc.
      - destruct (sem s1 y);
        applyDesc balanceL_Desc;
        solve_Desc.
    + (* more or less a copy-n-paste from above *)
      clear IHHB1.
      applyDesc IHHB2.

      rewrite (sem_outside_above HB1) by order_Bounds.
      replace (y == x) with false by order_Bounds.
      rewrite ?orb_false_r, ?orb_false_l.

      destruct_ptrEq.
      - replace (sem s2 y) with true
           by (destruct (sem s2 y) eqn:?; auto; exfalso; lia).
        solve_Desc.
      - destruct (sem s2 y);
        applyDesc balanceR_Desc;
        solve_Desc.
Qed.


Lemma insert_WF:
  forall y s, WF s -> WF (insert y s).
Proof. intros. eapply Desc_WF. eapply insert_Desc; try reflexivity; try assumption. Qed.

(** ** Verification of [maxViewSure] *)

Lemma maxViewSure_Desc:
  forall sz' x s1 s2 lb ub,
    Bounded (Bin sz' x s1 s2) lb ub ->
    forall P,
    (forall y r,
      ((y == x) = true \/ sem s2 y = true) /\
      Desc r lb (Some y) (size s1 + size s2)
                         (fun i => (sem s1 i || (i == x) || sem s2 i) && negb (i == y)) ->
      P (y, r)) ->
    P (maxViewSure x s1 s2).
    (* we know that y is in the input, and we actually know more: it is x or in s2 *)
Proof.
  intros ?????? HB.
  revert sz' x s1 lb ub HB.
  induction s2; intros sz' x s1 lb ub HB;subst.
  - clear IHs2_1.
    simpl.
    intros X HX; rewrite (surjective_pairing (maxViewSure _ _ _)). apply HX; clear X HX.

    inversion HB; subst; clear HB.
    inversion H4; subst.

    eapply IHs2_2; only 1: solve_Bounded; intros y r H; destruct H as [Hthere IHD]; clear IHs2_2.
    cbn -[Z.add size] in *; rewrite size_Bin in *.

    applyDesc IHD; clear IHD.

    split.
    + rewrite <- !orb_assoc. right. destruct Hthere as [H|H]; rewrite H;
      rewrite ?orb_true_r, ?orb_true_r; reflexivity.
    + destruct Hthere; applyDesc balanceL_Desc; solve_Desc.
  - intros X HX; rewrite (surjective_pairing (maxViewSure _ _ _)). apply HX; clear X HX.
    cbn -[Z.add size] in *.
    inversion HB; subst; clear HB.
    rewrite Eq_refl.
    split; [left; reflexivity | solve_Desc].
Qed.

(** ** Verification of [minViewSure] *)

Lemma minViewSure_Desc:
  forall sz' x s1 s2 lb ub,
    Bounded (Bin sz' x s1 s2) lb ub ->
    forall P,
    (forall y r,
      ((y == x) = true \/ sem s1 y = true) /\
      Desc r (Some y) ub (size s1 + size s2)
                         (fun i => (sem s1 i || (i == x) || sem s2 i) && negb (i == y)) ->
      P (y, r)) ->
    P (minViewSure x s1 s2).
    (* we know that y is in the input, and we actually know more: it is x or in s2 *)
Proof.
  intros ?????? HB.
  revert sz' x s2 lb ub HB.
  induction s1; intros sz' x s2 lb ub HB;subst.
  - clear IHs1_2.
    simpl.
    intros X HX; rewrite (surjective_pairing (minViewSure _ _ _)). apply HX; clear X HX.

    inversion HB; subst; clear HB.
    inversion H3; subst.

    eapply IHs1_1; only 1: solve_Bounded; intros y r [Hthere IHD]; clear IHs1_1.
    cbn -[Z.add size] in *; rewrite size_Bin in *.

    applyDesc IHD; clear IHD.

    split.
    + rewrite <- !orb_assoc. right. destruct Hthere as [H|H]; rewrite H;
      rewrite ?orb_true_r, ?orb_true_r; reflexivity.
    + destruct Hthere; applyDesc balanceR_Desc; solve_Desc.
  - intros X HX; rewrite (surjective_pairing (minViewSure _ _ _)). apply HX; clear X HX.
    cbn -[Z.add size] in *.
    inversion HB; subst; clear HB.
    rewrite Eq_refl.
    split; [left; reflexivity | solve_Desc].
Qed.

(** ** Verification of [glue] *)

Lemma glue_Desc:
  forall s1 s2 lb ub x,
  Bounded s1 lb (Some x) ->
  Bounded s2 (Some x) ub ->
  isLB lb x = true ->
  isUB ub x = true ->
  balance_prop (size s1) (size s2) ->
  Desc (glue s1 s2) lb ub ((size s1 + size s2)%Z) (fun i => sem s1 i || sem s2 i).
Proof.
  intros ????? HB1 HB2 ???.

  inversion HB1; inversion HB2; subst; cbn -[Z.add]; clear HB1 HB2.
  1-3: solve [solve_Desc|solve_size].
  destruct (Z.ltb_spec (1 + size s4 + size s5) (1 + size s0 + size s3)).
  - eapply maxViewSure_Desc; only 1: solve_Bounded.
    intros y r [Hthere HD].
    applyDesc HD.
    destruct Hthere; applyDesc balanceR_Desc; solve_Desc.
  - eapply minViewSure_Desc; only 1: solve_Bounded.
    intros y r [Hthere HD].
    applyDesc HD.
    destruct Hthere; applyDesc balanceL_Desc; solve_Desc.
Qed.

(** ** Verification of [delete] *)

Lemma delete_Desc :
  forall x s lb ub,
  Bounded s lb ub ->
  Desc (delete x s) lb ub (if sem s x then (size s - 1) else size s) (fun i => sem s i && negb (i == x)).
Proof.
  intros ???? HB.
  induction HB; intros; subst.
  - simpl. solve_Desc.
  - cbn -[Z.add].
    destruct (compare x x0) eqn:Heq.
    + replace (x == x0) with true by solve_Bounds.
      rewrite ?orb_true_r, ?orb_true_l.
      applyDesc glue_Desc.
      solve_Desc.
    + applyDesc IHHB1; clear IHHB1 IHHB2.
      replace (x == x0) with false by solve_Bounds.
      rewrite -> (sem_outside_below HB2) by solve_Bounds.
      rewrite ?orb_false_r.
      destruct_ptrEq.
      * replace (sem s1 x) with false by (destruct (sem s1 x); try congruence; lia).
        solve_Desc.
      * destruct (sem s1 x); applyDesc balanceR_Desc; solve_Desc.
    + applyDesc IHHB2; clear IHHB1 IHHB2.
      replace (x == x0) with false by solve_Bounds.
      rewrite -> (sem_outside_above HB1) by solve_Bounds.
      rewrite ?orb_false_l.
      destruct_ptrEq.
      * replace (sem s2 x) with false by (destruct (sem s2 x); try congruence; lia).
        solve_Desc.
      * destruct (sem s2 x); applyDesc balanceL_Desc; solve_Desc.
Qed.

(** ** Verification of [union] *)

Lemma splitS_Desc :
  forall x s lb ub,
  Bounded s lb ub ->
  forall (P : Set_ e * Set_ e -> Prop),
  (forall s1 s2,
    Bounded s1 lb (Some x) ->
    Bounded s2 (Some x) ub ->
    size s = size s1 + size s2 + (if sem s x then 1 else 0) ->
    (forall i, sem s i = (if i == x then sem s i else sem s1 i || sem s2 i)) ->
    P (s1, s2)) ->
  P (splitS x s) : Prop.
Proof.
  intros ?? ?? HB.
  Ltac solveThis := intros X HX; apply HX; clear X HX; [solve_Bounded|solve_Bounded| |f_solver].
  induction HB.
  - solveThis. reflexivity.
  - simpl.
    destruct (compare x x0) eqn:?.
  + solveThis. replace (x == x0) with true by order e.
    rewrite orb_true_r. simpl. lia.
  + apply IHHB1; intros s1_2 s1_3 HB1_2 HB1_3 Hsz Hsems1; clear IHHB1 IHHB2.
    applyDesc link_Desc.
    solveThis. destruct (sem s1 x). 
    * simpl. lia.
    * replace (x == x0) with false by order e. simpl.
      rewrite (sem_outside_below HB2) by solve_Bounds. lia.
  + apply IHHB2; intros s2_2 s2_3 HB2_2 HB2_3 Hsz Hsems2; clear IHHB1 IHHB2.
    applyDesc link_Desc.
    solveThis. destruct (sem s2 x). 
    * rewrite orb_true_r. lia.
    * replace (x == x0) with false by order e. simpl.
      rewrite (sem_outside_above HB1) by solve_Bounds. simpl. lia.
Qed.

(* The [union] uses some nested pattern match that expand to a very large
   number of patterns in Coq. So let’s take them apart here *)
Lemma union_destruct :
  forall (P : Set_ e -> Prop),
  forall s1 s2,
  (s2 = Tip -> P s1) ->
  (s1 = Tip -> P s2) ->
  (forall sz2 x, (s2 = Bin sz2 x Tip Tip) -> P (insertR x s1)) ->
  (forall sz1 x, (s1 = Bin sz1 x Tip Tip) -> P (insert x s2)) ->
  (forall sz1 x l1 r1, (s1 = Bin sz1 x l1 r1) -> 
    P (
      match splitS x s2 with
      | pair l2 r2 =>
      match union r1 r2 with
      | r1r2 =>
      match union l1 l2 with
      | l1l2 => if andb  (PtrEquality.ptrEq l1l2 l1)
                         (PtrEquality.ptrEq r1r2 r1) : bool
                then s1 else link x l1l2 r1r2
      end end end)) ->
  P (union s1 s2).
Proof.
  intros P s1 s2 HTipR HTipL HSingletonR HSingletonL HBins.
  destruct s1, s2; simpl union;
  try destruct s1_1, s1_2;
  try destruct s2_1, s2_2;
  first [ eapply HBins; reflexivity
        | eapply HSingletonL; reflexivity
        | eapply HSingletonR; reflexivity
        | eapply HTipL; reflexivity
        | eapply HTipR; reflexivity
        | idtac
        ].
Qed. 

Lemma union_Desc :
  forall s1 s2 lb ub,
  Bounded s1 lb ub ->
  Bounded s2 lb ub ->
  Desc' (union s1 s2) lb ub (fun i => sem s1 i || sem s2 i).
(* We use [Desc'] here, because the result of [union] is passed to [link], which
   does a full rebalance, and hence does not need to know anything about the size.
   If it turns out we need [size (union s1 s2)], we can still add it.
*)
Proof.
  intros ???? HB1 HB2.
  revert s2 HB2.
  induction HB1; intros s3 HB3.
  * apply union_destruct; intros; subst; try congruence.
    + solve_Desc.
    + solve_Desc.
    + inversion HB3; subst; clear HB3.
      clear H3 H4.
      (* We need to give [applyDesc] a hint about the bounds that we care about: *)
      assert (Bounded Tip lb ub) by constructor.
      applyDesc insertR_Desc.
      solve_Desc.
  * apply union_destruct; intros; subst; try congruence.
    + solve_Desc.
    + inversion HB3; subst; clear HB3.
      applyDesc insertR_Desc.
      solve_Desc.
    + inversion H3; subst; clear H3.
      applyDesc insert_Desc. solve_Desc.
    + inversion H3; subst; clear H3.
      eapply splitS_Desc; try eassumption.
      intros.
      applyDesc IHHB1_1.
      applyDesc IHHB1_2.
      destruct_ptrEq.
      - solve_Desc.
      - applyDesc link_Desc.
        solve_Desc.
Qed.


(** ** Verification of [merge] *)

Lemma merge_eq: forall (l r: Set_ e), merge l r = 
  match l, r with 
  | Tip, r => r
  | l, Tip => l
  | (Bin sizeL x lx rx as l), (Bin sizeR y ly ry as r) =>
    if Sumbool.sumbool_of_bool
         ((delta GHC.Num.* sizeL) GHC.Base.< sizeR)
    then balanceL y (merge l ly) ry           
    else if Sumbool.sumbool_of_bool
              ((delta GHC.Num.* sizeR) GHC.Base.< sizeL)
         then balanceR x lx (merge rx r)
         else glue l r
  end.
Proof.
  unfold merge at 1, merge_func at 1.
  destruct l; only 2: reflexivity.
  destruct r; only 2: reflexivity.
  lazymatch goal with 
    |- Wf.Fix_sub ?A ?R ?Rwf ?P ?F_sub ?x = ?rhs => 
    apply (@Wf.WfExtensionality.fix_sub_eq_ext A R Rwf P F_sub x)
  end.
Qed.


Program Fixpoint merge_Desc (s1: Set_ e)  (s2: Set_ e)
  {measure (set_size s1 + set_size s2)} :
    forall x lb ub,
      Bounded s1 lb (Some x) ->
      Bounded s2 (Some x) ub  ->
      isLB lb x = true ->
      isUB ub x = true->
      Desc (merge s1 s2) lb ub (size s1 + size s2)
           (fun i => sem s1 i || sem s2 i)
  := _.
Next Obligation.
  intros.
  rewrite merge_eq. 
  inversion H; subst; clear H;
    inversion H0; subst; clear H0;
      try solve [solve_Desc].
  destruct (Sumbool.sumbool_of_bool _);
    only 2: destruct (Sumbool.sumbool_of_bool _);
    rewrite ?Z.ltb_lt, ?Z.ltb_ge in *.
  - applyDesc merge_Desc.
    applyDesc balanceL_Desc.
    solve_Desc.
  - applyDesc merge_Desc.
    applyDesc balanceR_Desc.
    solve_Desc.
  - applyDesc glue_Desc.
    solve_Desc.
Qed.

Lemma splitMember_Desc:
  forall x s lb ub,
  Bounded s lb ub ->
  forall (P : Set_ e * bool * Set_ e -> Prop),
  (forall s1 b s2,
    Bounded s1 lb (Some x) ->
    Bounded s2 (Some x) ub ->
    (forall i, sem s i =
          (if i == x then b 
           else  (sem s1 i || sem s2 i))) ->
    P (s1, b, s2)) ->
  P (splitMember x s) : Prop.
Proof.
  intros ?? ?? HB.
  induction HB.
  Ltac solveThis ::= intros X HX; apply HX; clear X HX; [solve_Bounded|solve_Bounded|f_solver].
  * solveThis.
  * simpl.
    destruct (compare x x0) eqn:?.
    + solveThis.
    + apply IHHB1.
      intros s1_2 b s1_3 HB1_2 HB1_3 Hsems1.
      clear IHHB1 IHHB2.
      applyDesc link_Desc.
      solveThis.
    + apply IHHB2.
      intros s2_2 b s2_3 HB2_2 HB2_3 Hsems2.
      clear IHHB1 IHHB2.
      applyDesc link_Desc.
      solveThis.
Qed.

Lemma intersection_Desc:
  forall s1 s2 lb ub,
  Bounded s1 lb ub ->
  Bounded s2 lb ub ->
  Desc' (intersection s1 s2) lb ub
        (fun i => sem s1 i && sem s2 i).
Proof.
  intros ???? HB1 HB2.
  revert s2 HB2.
  induction HB1; intros s3 HB3.
  - simpl. solve_Desc.
  - simpl.
    destruct s3 eqn:Hs3.
    + rewrite<- Hs3 in *.
      clear Hs3 e0 s4 s5 s6.
      eapply splitMember_Desc;
        only 1: eassumption.
      intros s4' b s5' HB1 HB2 Hi.  
      applyDesc IHHB1_1.
      applyDesc IHHB1_2.
      destruct b.
      * destruct_ptrEq.
        -- solve_Desc.
        -- applyDesc link_Desc.
           solve_Desc.
      * applyDesc merge_Desc.
        solve_Desc.
    + solve_Desc.
Qed.

(** ** Verification of [difference] *)

Lemma split_Desc :
  forall x s lb ub,
  Bounded s lb ub ->
  forall (P : Set_ e * Set_ e -> Prop),
  (forall s1 s2,
    Bounded s1 lb (Some x) ->
    Bounded s2 (Some x) ub ->
    (size s = size s1 + size s2 + (if sem s x then 1 else 0)) ->
    (forall i, sem s i = (if i == x then sem s i else sem s1 i || sem s2 i)) ->
    P (s1, s2)) ->
  P (split x s) : Prop.
Proof.
  unfold split.
  intros x s.
  replace (Datatypes.id GHC.Base.$ splitS x s) with (splitS x s).
  apply splitS_Desc.
  reflexivity.
Qed.

Lemma difference_destruct :
  forall (P : Set_ e -> Prop),
  forall s1 s2,
  (s1 = Tip -> P Tip) ->
  (s2 = Tip -> P s1) ->
  (forall sz2 x l2 r2, (s2 = Bin sz2 x l2 r2) -> 
    P (
      match split x s1 with
      | pair l1 r1 =>
      match difference r1 r2 with
      | r1r2 =>
      match difference l1 l2 with
      | l1l2 => if size l1l2 + size r1r2 == size s1
                then s1 else merge l1l2 r1r2
      end end end)) ->
  P (difference s1 s2).
Proof.
  intros P s1 s2 HTipL HTipR HBins.
  destruct s1, s2; simpl difference;
  try destruct s1_1, s1_2;
  try destruct s2_1, s2_2;
  first [ eapply HBins; reflexivity
        | eapply HTipL; reflexivity
        | eapply HTipR; reflexivity
        | idtac
        ].
Qed.

Lemma difference_Desc :
  forall s1 s2 lb ub,
  Bounded s1 lb ub ->
  Bounded s2 lb ub ->
  forall (P : Set_ e -> Prop),
  (forall s,
    Bounded s lb ub ->
    size s <= size s1 ->
    (size s = size s1 -> forall i, sem s i = sem s1 i) ->
    (forall i, sem s i = sem s1 i && negb (sem s2 i)) ->
    P s) ->
  P (difference s1 s2).
Proof.
  intros s1 s2 lb ub Hb1 Hb2.
  revert s1 Hb1. induction Hb2; intros sl Hb1; apply hide.
  Ltac showP := apply unhide; intros X HX; apply HX; clear X HX; only 3: intro.
  - simpl.
    destruct sl; (showP; [assumption | reflexivity | reflexivity | f_solver]).
  - apply difference_destruct; intros; subst.
    + (showP; [assumption | reflexivity | reflexivity | f_solver]).
    + (showP; [assumption | reflexivity | reflexivity | f_solver]). 
    + eapply split_Desc; try eassumption. 
      intros sl1 sl2 HBsl1 HBsl2 Hsz Hsem. inversion H3; subst; clear H3.
      eapply IHHb2_1. solve_Bounded. intros sil ????.
      eapply IHHb2_2. solve_Bounded. intros sir ????.
      destruct (_ == _) eqn:Hcomp.
      * showP; [assumption | reflexivity | reflexivity | ].
        assert (size sl1 + size sl2 <= size sl) by (destruct (sem sl x0); lia).
        change (size sil + size sir =? size sl = true) in Hcomp.
        rewrite Z.eqb_eq in Hcomp.
        lapply H4; [intro; subst|lia].
        lapply H8; [intro; subst|lia].
        assert (sem sl x0 = false) by (destruct (sem sl x0); try reflexivity; lia).
        f_solver.
      * applyDesc merge_Desc.
        showP.
        -- assumption.
        -- destruct (sem sl x0); lia.
        -- assert (sem sl x0 = false) by (destruct (sem sl x0); try reflexivity; lia).
           rewrite H11 in Hsz.
           lapply H4; [intro; subst|lia].
           lapply H8; [intro; subst|lia].
           clear H4 H8.
           f_solver.
        -- f_solver.
Qed.

(** ** Verification of [foldr] *)

(** This relates [foldr] and [toList]. Hard to say which one is more primitive. *)

Lemma fold_right_toList_go:
  forall {a} k (n : a) s (xs : list e),
  fold_right k n (foldr cons xs s) = foldr k (fold_right k n xs) s.
Proof.
  intros. 
  revert xs; induction s; intros.
  * simpl.
    rewrite IHs1.
    simpl.
    rewrite IHs2.
    reflexivity.
  * reflexivity.
Qed.


Lemma foldr_spec:
  forall {a} k (n : a) (s : Set_ e),
  foldr k n s = fold_right k n (toList s).
Proof.
  intros.
  unfold toList, toAscList. simpl.
  erewrite fold_right_toList_go by eassumption.
  reflexivity.
Qed.

(** ** Verification of [toList] and [toAscList] *)

Import ListNotations.

Lemma foldr_const_append:
  forall xs (s : Set_ e),
  foldr cons xs s = toList s ++ xs.
Proof.
  intros. revert xs. induction s; intros xs.
  * unfold toList, toAscList.
    simpl.
    rewrite !IHs2, !IHs1.
    rewrite app_nil_r.
    rewrite <- !app_assoc.
    reflexivity.
  * reflexivity.
Qed.

Lemma toList_Bin:
  forall sz x (s1 s2 : Set_ e),
  toList (Bin sz x s1 s2) = toList s1 ++ [x] ++ toList s2.
Proof.
  intros.
  unfold toList at 1, toAscList at 1.
  simpl.
  rewrite !foldr_const_append.
  rewrite app_nil_r.
  reflexivity.
Qed.

Lemma elem_app:
  forall {a} `{Eq_ a} (i : a) xs ys,
  List.elem i (xs ++ ys) = List.elem i xs || List.elem i ys.
Proof.
  intros.
  induction xs.
  * reflexivity.
  * simpl. rewrite IHxs. rewrite orb_assoc. reflexivity.
Qed.

Lemma toList_sem:
  forall s lb ub, Bounded s lb ub ->
  forall i, sem s i = List.elem i (toList s).
Proof.
  intros.
  induction H.
  * simpl. reflexivity.
  * rewrite toList_Bin.
    simpl.
    rewrite IHBounded1, IHBounded2; clear IHBounded1 IHBounded2.
    rewrite elem_app.
    simpl.
    rewrite orb_assoc. reflexivity.
Qed.

Lemma toList_lb:
  forall s lb ub, Bounded s lb ub ->
  Forall (fun i => isLB lb i = true) (toList s).
Proof.
  intros.
  induction H.
  * apply Forall_nil.
  * rewrite toList_Bin.
    rewrite Forall_forall in *.
    intros y Hi.
    simpl in Hi.
    rewrite !in_app_iff in *.
    destruct Hi as [?|[?|?]].
    - intuition.
    - subst. assumption.
    - enough(isLB (Some x) y = true) by order_Bounds. 
      intuition.
Qed.

Lemma toList_ub:
  forall s lb ub, Bounded s lb ub ->
  Forall (fun i => isUB ub i = true) (toList s).
Proof.
  intros.
  induction H.
  * apply Forall_nil.
  * rewrite toList_Bin.
    rewrite Forall_forall in *.
    intros y Hi.
    simpl in Hi.
    rewrite !in_app_iff in *.
    destruct Hi as [?|[?|?]].
    - enough(isUB (Some x) y = true) by order_Bounds. 
      intuition.
    - subst. assumption.
    - intuition.
Qed.


(** *** Sortedness of [toList] *)

Require Import Coq.Sorting.Sorted.

Close Scope Z.
Local Definition lt : e -> e -> Prop
  := fun x y => (x < y) = true.

Lemma sorted_append:
  forall l1 l2 (x : e),
  StronglySorted lt l1 ->
  StronglySorted lt l2 ->
  (forall y, In y l1 -> (y < x) = true) ->
  (forall y, In y l2 -> (x <= y) = true) ->
  StronglySorted lt (l1 ++ l2).
Proof.
  intros ??? Hsorted1 Hsorted2 Hlt Hge.
  induction Hsorted1.
  * apply Hsorted2.
  * simpl. apply SSorted_cons.
    + apply IHHsorted1.
      intros y Hy.
      apply Hlt.
      right.
      assumption.
    + rewrite Forall_forall.
      intros z Hz.
      rewrite in_app_iff in Hz.
      destruct Hz.
      - rewrite Forall_forall in H.
        apply H; auto.
      - assert (lt a x) by (apply Hlt; left; reflexivity).
        assert (x <= z = true) by (apply Hge; assumption).
        (unfold lt in *; order e).
Qed.

Lemma All_lt_elem:
  forall x i xs,
  Forall (lt x) xs ->
  List.elem i xs = true ->
  x < i = true.
Proof.
  intros.
  induction H.
  * simpl in H0. inversion H0.
  * simpl in *.
    rewrite orb_true_iff in H0.
    destruct H0.
    - unfold lt in *. order e.
    - intuition.
Qed.

Lemma to_List_sorted:
  forall s lb ub,
  Bounded s lb ub ->
  StronglySorted lt (toList s).
Proof.
  intros.
  induction H.
  * apply SSorted_nil.
  * rewrite toList_Bin.
    apply sorted_append with (x := x); only 2: apply SSorted_cons.
    - assumption.
    - assumption.
    - apply toList_lb in H0. simpl in H0.
      apply H0.
    - intros.
      apply toList_ub in H. simpl in H.
      rewrite Forall_forall in H.
      apply H; assumption.
    - intros.
      simpl in H5.
      destruct H5.
      + subst. order e.
      + apply toList_lb in H0. simpl in H0.
        rewrite Forall_forall in H0.
        assert (x < y = true) by (apply H0; assumption).
        order e.
Qed.

(** This relates [foldl] and [toList]. *)

Lemma foldl_spec:
  forall {a} k (n : a) (s : Set_ e),
  foldl k n s = fold_left k (toList s) n.
Proof.
  intros ????.
  revert n.
  induction s; intros n.
  * simpl.
    rewrite toList_Bin.
    rewrite IHs1.
    rewrite IHs2.
    simpl.
    rewrite fold_left_app.
    reflexivity.
  * reflexivity.
Qed.

(** Size *)

Lemma size_spec:
  forall s lb ub,
  Bounded s lb ub ->
  size s = Z.of_nat (length (toList s)).
Proof.
  intros.
  induction H.
  * reflexivity.
  * rewrite toList_Bin.
    rewrite app_length.
    simpl.
    rewrite H3, IHBounded1, IHBounded2.
    lia.
Qed.

(** Equality *)

Lemma eqlist_sym:
  forall {a} `{EqLaws a} (xs ys : list a),
  eqlist xs ys = eqlist ys xs.
Proof.
  intros. revert ys.
  induction xs; intros ys; destruct ys; simpl in *; try congruence.
  rewrite Eq_sym. rewrite IHxs.
  reflexivity.
Qed.

Lemma eqlist_length:
  forall {a} `{Eq_ a} (xs ys : list a),
  eqlist xs ys = true ->
  length xs = length ys.
Proof.
  intros. revert ys H0.
  induction xs; intros ys Heqlist; destruct ys; simpl in *; try congruence.
  rewrite andb_true_iff in Heqlist; destruct Heqlist.
  erewrite -> IHxs by eassumption.
  reflexivity.
Qed.

Lemma eqlist_elem:
  forall {a} `{EqLaws a} (xs ys : list a) (x : a),
  eqlist xs ys = true ->
  List.elem x xs = List.elem x ys.
Proof.
  intros. revert ys H1.
  induction xs; intros ys H1; destruct ys; simpl in *; try congruence.
  rewrite andb_true_iff in H1; destruct H1.
  erewrite IHxs by eassumption.
  f_equal.
  rewrite eq_iff_eq_true.
  split; intro.
  - eapply Eq_trans; eassumption.
  - rewrite Eq_sym in H1. eapply Eq_trans; eassumption.
Qed.


Lemma sem_false_nil:
  forall s, (forall i, sem s i = false) -> s = Tip.
Proof.
  intros.
  destruct s; try reflexivity; exfalso.
  specialize (H e0).
  simpl in H.
  rewrite Eq_refl in H.
  rewrite orb_true_r in H.
  simpl in H.
  congruence.
Qed.

Lemma strongly_sorted_unique:
  forall (xs ys : list e),
  StronglySorted lt xs ->
  StronglySorted lt ys ->
  (forall x, List.elem x xs = List.elem x ys) ->
  eqlist xs ys = true.
Proof.
  intros.
  revert dependent ys.
  induction H; intros ys Hys Helem; inversion Hys; subst; clear Hys.
  * reflexivity.
  * specialize (Helem a). simpl in Helem. rewrite Eq_refl in Helem. inversion Helem.
  * specialize (Helem a). simpl in Helem. rewrite Eq_refl in Helem. inversion Helem.
  * simpl. rewrite andb_true_iff.
    assert (a == a0 = true).
    { clear IHStronglySorted.
      pose proof (Helem a) as Ha.
      pose proof (Helem a0) as Ha0.
      simpl in Ha, Ha0.
      rewrite Eq_refl in Ha, Ha0; rewrite ?orb_true_l, ?orb_true_r in Ha, Ha0.
      symmetry in Ha.
      rewrite orb_true_iff in Ha, Ha0.
      destruct Ha, Ha0; only 1-3 : order e; exfalso.
      pose proof (All_lt_elem _ _ _ H0 H4).
      pose proof (All_lt_elem _ _ _ H2 H3).
      order e.
    }
    split; try assumption.
    apply IHStronglySorted; clear IHStronglySorted.
      + assumption.
      + intros i.
        specialize (Helem i).
        simpl in Helem.
        destruct (List.elem i l) eqn:?, (List.elem i l0) eqn:?;
          rewrite ?orb_true_l, ?orb_true_r, ?orb_false_l, ?orb_false_r  in Helem;
          try reflexivity;
          try solve [order e].
        - pose proof (All_lt_elem _ _ _ H0 Heqb). order e.
        - pose proof (All_lt_elem _ _ _ H2 Heqb0). order e.
Qed.

Lemma equals_spec:
  forall s1 s2 lb ub,
  Bounded s1 lb ub ->
  Bounded s2 lb ub ->
  s1 == s2 = true <-> (forall i, sem s1 i = sem s2 i).
Proof.
  intros.
  unfold op_zeze__, Eq___Set_, op_zeze____.
  unfold Internal.Eq___Set__op_zeze__.
  unfold op_zeze__, Eq_Integer___, Eq_list, op_zeze____.
  rewrite andb_true_iff.
  split; intro.
  * destruct H1.
    intro i.
    erewrite !toList_sem by eassumption.
    erewrite eqlist_elem by eassumption.
    reflexivity.
  * erewrite !size_spec by eassumption.
    assert (Heqlist : eqlist (toList s1) (toList s2) = true).
    { apply strongly_sorted_unique.
      * eapply to_List_sorted; eassumption.
      * eapply to_List_sorted; eassumption.
      * intros i; specialize (H1 i).
        erewrite !toList_sem in H1 by eassumption.
        assumption.
    }
    erewrite  eqlist_length by eassumption.
    rewrite Z.eqb_refl. intuition.
Qed.

(** ** Verifying [isSubsetOf] *)

Lemma isSubsetOfX_spec:
  forall s1 s2 lb ub,
  Bounded s1 lb ub ->
  Bounded s2 lb ub ->
  isSubsetOfX s1 s2 = true <-> (forall i, sem s1 i = true -> sem s2 i = true).
Proof.
  intros ???? HB1 HB2.
  revert dependent s2.
  induction HB1; intros; simpl; subst.
  * intuition.
  * destruct s0 eqn:Hs0.
    - rewrite <- Hs0 in *.
      clear s3 e0 s4 s5 Hs0.
      eapply splitMember_Desc; [solve_Bounded|].
      intros sr1 b sr2 HBsr1 HBsr2 Hsem.
      rewrite !andb_true_iff.
      rewrite IHHB1_1 by eassumption.
      rewrite IHHB1_2 by eassumption.
      split; intro; [destruct H1 as [?[??]] | split; [|split] ].
      -- intros i Hi.
         rewrite Hsem.
         rewrite !orb_true_iff in Hi.
         destruct Hi as [[Hi|Hi]|Hi];
         destruct (i == x);
         try reflexivity;
         try congruence;
         try apply H3 in Hi;
         try apply H4 in Hi;
         rewrite Hi;
         rewrite ?orb_true_l, ?orb_true_r; reflexivity.
     -- specialize (Hsem x).
        rewrite Eq_refl in Hsem. rewrite <- Hsem.
        apply H1.
        rewrite Eq_refl.
        rewrite ?orb_true_l, ?orb_true_r; reflexivity.
     -- intros i Hi.
        specialize (H1 i).
        rewrite Hi in H1.
        rewrite ?orb_true_l, ?orb_true_r in H1.
        rewrite Hsem in H1.
        specialize (H1 eq_refl).
        repeat (f_solver_step; f_solver_cleanup).
     -- intros i Hi.
        specialize (H1 i).
        rewrite Hi in H1.
        rewrite ?orb_true_l, ?orb_true_r in H1.
        rewrite Hsem in H1.
        specialize (H1 eq_refl).
        repeat (f_solver_step; f_solver_cleanup).
    - intuition.
      specialize (H1 x).
      rewrite Eq_refl, orb_true_r in H1.
      simpl in H1. intuition.
Qed.

Lemma subest_size:
  forall s1 s2 lb ub,
  Bounded s1 lb ub ->
  Bounded s2 lb ub ->
  (forall i, sem s1 i = true -> sem s2 i = true) ->
  (size s1 <= size s2)%Z.
Proof.
  intros ???? HB1 HB2 Hsubset.
  revert dependent s2.
  induction HB1; intros; simpl; subst.
  * simpl. solve_size.
  * assert (sem s0 x = true)
      by (apply Hsubset; simpl; rewrite Eq_refl, orb_true_r; reflexivity).
    assert (size s0 = let '(sl,sr) := split x s0 in 1 + size sl + size sr)%Z.
    { eapply split_Desc; [eassumption|]. intros. rewrite H1 in H5. lia. }
    rewrite H3.
    eapply split_Desc; [eassumption|]. intros.
    assert (size s1 <= size s3)%Z.
    { apply IHHB1_1; try assumption.
      intros i Hi.
      specialize (Hsubset i). simpl in Hsubset.
      rewrite Hi in Hsubset. rewrite orb_true_l in Hsubset.
      specialize (Hsubset eq_refl).
      rewrite H7 in Hsubset.
      repeat (f_solver_step; f_solver_cleanup).
    }
    assert (size s2 <= size s4)%Z.
    { apply IHHB1_2; try assumption.
      intros i Hi.
      specialize (Hsubset i). simpl in Hsubset.
      rewrite Hi in Hsubset. rewrite orb_true_r in Hsubset.
      specialize (Hsubset eq_refl).
      rewrite H7 in Hsubset.
      repeat (f_solver_step; f_solver_cleanup).
    }
    lia.
Qed.

Lemma isSubsetOf_spec:
  forall s1 s2 lb ub,
  Bounded s1 lb ub ->
  Bounded s2 lb ub ->
  isSubsetOf s1 s2 = true <-> (forall i, sem s1 i = true -> sem s2 i = true).
Proof.
  intros.
  unfold isSubsetOf.
  rewrite andb_true_iff.
  erewrite isSubsetOfX_spec by eassumption.
  intuition.
  unfold op_zlze__, Ord_Integer___, op_zlze____.
  rewrite Z.leb_le.
  eapply subest_size; eassumption.
Qed.


(** ** Verifying [filter] *)

Require Import Coq.Classes.Morphisms. (* For [Proper] *)

(**
For filter we need two lemmas: We need to know that [filter P s] is
well-formed even if P does not respect equality (this is
required by the [FSetInterface]). But to prove something about its
semantics, we need to assume that [P] respects equality.
*)

Lemma filter_Bounded:
  forall (P : e -> bool) s lb ub,
  Bounded s lb ub ->
  Bounded (Internal.filter P s) lb ub.
Proof.
  intros.
  induction H.
  * simpl. solve_Bounded.
  * simpl.
    destruct (P x) eqn:HPx.
    - destruct_ptrEq.
      + solve_Bounded.
      + applyDesc link_Desc.
    - applyDesc merge_Desc.
Qed.

Lemma filter_Desc:
  forall (P : e -> bool) s lb ub,
  Bounded s lb ub ->
  Proper ((fun i j : e => _GHC.Base.==_ i j = true) ==> eq) P ->
  Desc' (Internal.filter P s) lb ub (fun i => P i && sem s i).
Proof.
  intros.
  induction H.
  * simpl. solve_Desc.
  * simpl.
    applyDesc IHBounded1.
    applyDesc IHBounded2.
    destruct (P x) eqn:HPx.
    - destruct_ptrEq.
      + solve_Desc.
        f_solver.
        specialize (H0 _ _ Heqb0). congruence.
      + applyDesc link_Desc.
        solve_Desc.
        f_solver.
        specialize (H0 _ _ Heqb0). congruence.
    - applyDesc merge_Desc.
      solve_Desc.
      f_solver.
      specialize (H0 _ _ Heqb2). congruence.
Qed.

(** ** Verifying [partition] *)

Lemma partition_Bounded:
  forall p s lb ub,
  Bounded s lb ub ->
  forall (P : (Set_ e * Set_ e) -> Prop),
  (forall s1 s2, Bounded s1 lb ub /\ Bounded s2 lb ub -> P (s1, s2)) ->
  P (partition p s).
Proof.
  intros ???? HB.
  induction HB.
  * intros X HX; apply HX; clear X HX; split; solve_Bounded.
  * simpl.
    apply IHHB1; intros sl1 sl2 [HDsl1 HDsl2]; clear IHHB1.
    apply IHHB2; intros sr1 sr2 [HDsr1 HDsr2]; clear IHHB2.
    destruct (p x) eqn:?.
    - intros X HX; apply HX; clear X HX; split.
      + destruct_ptrEq.
        -- solve_Bounded.
        -- applyDesc link_Desc.
      + applyDesc merge_Desc.
    - intros X HX; apply HX; clear X HX; split.
      + applyDesc merge_Desc.
      + destruct_ptrEq.
        -- solve_Bounded.
        -- applyDesc link_Desc.
Qed.


Lemma partition_spec:
  forall p s lb ub,
  Bounded s lb ub ->
  Proper ((fun i j : e => i == j = true) ==> eq) p ->
  forall (P : (Set_ e * Set_ e) -> Prop),
  (forall s1 s2,
    Desc' s1 lb ub (fun i => p i && sem s i) /\
    Desc' s2 lb ub (fun i => negb (p i) && sem s i) ->
    P (s1, s2)) ->
  P (partition p s).
Proof.
  intros ???? HB HProper.
  induction HB.
  * intros X HX; apply HX; clear X HX; split; solve_Desc.
  * simpl.
    apply IHHB1; intros sl1 sl2 [HDsl1 HDsl2]; clear IHHB1.
    applyDesc HDsl1; clear HDsl1.
    applyDesc HDsl2; clear HDsl2.
    apply IHHB2; intros sr1 sr2 [HDsr1 HDsr2]; clear IHHB2.
    applyDesc HDsr1; clear HDsr1.
    applyDesc HDsr2; clear HDsr2.
    destruct (p x) eqn:?.
    - intros X HX; apply HX; clear X HX; split.
      + destruct_ptrEq.
        -- solve_Desc.
           f_solver.
           specialize (HProper _ _ Heqb1). congruence.
        -- applyDesc link_Desc.
           solve_Desc.
           f_solver.
           specialize (HProper _ _ Heqb1). congruence.
      + applyDesc merge_Desc.
        solve_Desc.
        f_solver.
        specialize (HProper _ _ Heqb3). congruence.
    - intros X HX; apply HX; clear X HX; split.
      + applyDesc merge_Desc.
        solve_Desc.
        f_solver.
        specialize (HProper _ _ Heqb3). congruence.
      + destruct_ptrEq.
        -- solve_Desc.
           f_solver.
           specialize (HProper _ _ Heqb1). congruence.
        -- applyDesc link_Desc.
           solve_Desc.
           f_solver.
           specialize (HProper _ _ Heqb1). congruence.
Qed.


End WF.




(** * Instantiating the [FSetInterface] *)

Require Import Coq.FSets.FSetInterface.
Require OrdTheories.

Module SetWSfun (E : OrderedType) <: WSfun(E).
  Include OrdTheories.OrdTheories E.

  Lemma E_eq_zeze:
    forall x y : elt, E.eq x y <-> (x == y) = true.
  Proof. apply elt_eq. Qed.

  Lemma E_lt_zl:
    forall x y : elt, E.lt x y <-> (x < y) = true.
  Proof. apply elt_lt. Qed.
  
  Lemma InA_Eeq_elem:
    forall x xs,  
    InA E.eq x xs <-> List.elem x xs = true.
  Proof.
    intros.
    induction xs.
    * simpl. split; intro; inversion H.
    * simpl. rewrite InA_cons, orb_true_iff, IHxs, elt_eq. reflexivity.
  Qed.

  Lemma compat_bool_Eeq_op_zeze:
    forall f, compat_bool E.eq f ->
    Proper ((fun i j : elt => i == j = true) ==> eq) f.
  Proof.
    intros.
    intros i j Heq.
    rewrite <- E_eq_zeze in Heq.
    apply H. assumption.
  Qed.

  (* Well-formedness *)
  Definition t := {s : Set_ elt | Bounded s None None}.
  Program Definition In (x :elt) (s : t) : Prop := sem s x = true.

  Definition Equal s s' := forall a : elt, In a s <-> In a s'.
  Definition Subset s s' := forall a : elt, In a s -> In a s'.
  Definition Empty s := forall a : elt, ~ In a s.

  Program Definition empty : t := empty.
  Next Obligation. constructor. Defined.

  Program Definition is_empty : t -> bool := null.

  Lemma empty_1 : Empty empty.
  Proof. intros x H. inversion H. Qed.

  Lemma Empty_tip : forall s, Empty s <-> proj1_sig s = Tip.
  Proof.
    intros. split; intro.
    * destruct s as [[|]?].
      + exfalso. specialize (H e).
        contradict H.
        unfold In. simpl. rewrite Eq_refl, orb_true_r. reflexivity.
      + reflexivity.
    * intros x H1. inversion H1. rewrite H in H2. inversion H2.
  Qed.

  Lemma is_empty_1 : forall s : t, Empty s -> is_empty s = true.
  Proof.
    intros.
    rewrite Empty_tip in *.
    unfold is_empty in *.
    rewrite H. reflexivity.
  Qed.

  Lemma is_empty_2 : forall s : t, is_empty s = true -> Empty s.
  Proof.
    intros.
    rewrite Empty_tip in *.
    unfold is_empty in *.
    destruct (proj1_sig s); [ inversion H | reflexivity].
  Qed.
  
  Definition eq : t -> t -> Prop := Equal.
  Definition eq_dec : forall s s' : t, {eq s s'} + {~ eq s s'}.
  Proof.
    intros.
    destruct s as [s1 ?], s' as [s2 ?].
    unfold eq, Equal, In, proj1_sig.
    destruct (s1 == s2) eqn:?.
    * left. intro i.  apply eq_iff_eq_true. eapply equals_spec; try eassumption.
    * right.
      assert (~ (forall a : elt, sem s1 a = sem s2 a)).
      { rewrite <- equals_spec by eassumption.
        rewrite not_true_iff_false. assumption.
      }
      contradict H. intro i. apply eq_iff_eq_true. apply H.
  Qed.

  Lemma eq_refl : forall s : t, eq s s.
  Proof. destruct s. unfold eq. unfold Equal. intro. reflexivity. Qed.

  Lemma eq_sym : forall s s' : t, eq s s' -> eq s' s.
  Proof. destruct s; destruct s'; 
    unfold eq, Equal in *. intros. rewrite H. intuition. Qed.

  Lemma eq_trans :
    forall s s' s'' : t, eq s s' -> eq s' s'' -> eq s s''.
  Proof.
    destruct s; destruct s'; destruct s''; simpl.
    unfold eq, Equal. intros ???. rewrite H, H0. reflexivity.
  Qed.

  Program Definition mem : elt -> t -> bool := member.

  Program Definition singleton : elt -> t := singleton.
  Next Obligation. eapply singleton_Desc with (ub := None) (lb := None); intuition. Qed.

  Program Definition add : elt -> t -> t := insert.
  Next Obligation.
    destruct x0. simpl.
    eapply insert_Desc with (ub := None) (lb := None); intuition.
  Qed.

  Program Definition remove : elt -> t -> t := delete.
  Next Obligation.
    destruct x0. simpl.
    eapply delete_Desc with (ub := None) (lb := None); intuition.
  Qed.

  Program Definition union : t -> t -> t := union.
  Next Obligation.
    destruct x, x0. simpl.
    eapply union_Desc with (ub := None) (lb := None); intuition.
  Qed.

  Program Definition inter : t -> t -> t:= intersection.
  Next Obligation.
    destruct x, x0. simpl.
    eapply intersection_Desc with (ub := None) (lb := None);intuition.
  Qed.

  Program Definition diff : t -> t -> t := difference.
  Next Obligation.
    destruct x, x0. simpl.
    eapply difference_Desc with (ub := None) (lb := None); intuition.
  Qed.

  Program Definition equal : t -> t -> bool := fun s1 s2 => @op_zeze__ (Set_ elt) _ s1 s2.
  Program Definition subset : t -> t -> bool := isSubsetOf.

  Program Definition fold : forall A : Type, (elt -> A -> A) -> t -> A -> A
    := fun a k s n => foldl (fun x e => k e x) n s.

  Program Definition filter : (elt -> bool) -> t -> t := filter.
  Next Obligation.
    destruct x0. simpl.
    eapply filter_Bounded with (ub := None) (lb := None); assumption.
  Qed.

  Program Definition partition : (elt -> bool) -> t -> t * t := partition.
  Next Obligation.
    destruct x0. simpl.
    eapply partition_Bounded with (ub := None) (lb := None); intuition.
  Qed.
  Next Obligation.
    destruct x0. simpl.
    eapply partition_Bounded with (ub := None) (lb := None); intuition.
  Qed.

  Program Definition cardinal : t -> nat := fun s => Z.to_nat (size s).
  Program Definition elements : t -> list elt := toList.

  Lemma In_1 :
    forall (s : t) (x y : elt), E.eq x y -> In x s -> In y s.
  Proof.
    intros [s?] x y Heq.
    rewrite E_eq_zeze in Heq.
    unfold In, proj1_sig.
    rewrite (sem_resp_eq _ _ _ Heq).
    intuition.
  Qed.

  Lemma mem_1 : forall (s : t) (x : elt), In x s -> mem x s = true.
  Proof.
    intros. destruct s. unfold In, mem in *. simpl in *.
    erewrite member_spec; eassumption.
  Qed.

  Lemma mem_2 : forall (s : t) (x : elt), mem x s = true -> In x s.
  Proof.
    intros. destruct s. unfold In, mem in *. simpl in *.
    erewrite member_spec in H; eassumption.
  Qed.

  Lemma equal_1 : forall s s' : t, Equal s s' -> equal s s' = true.
  Proof.
    intros [s1?] [s2?].
    unfold Equal, equal, In, proj1_sig.
    rewrite equals_spec by eassumption.
    intros. apply eq_iff_eq_true. apply H.
  Qed.
  
  Lemma equal_2 : forall s s' : t, equal s s' = true -> Equal s s'.
  Proof.
    intros [s1?] [s2?].
    unfold Equal, equal, In, proj1_sig.
    rewrite equals_spec by eassumption.
    intros. apply eq_iff_eq_true. apply H.
  Qed.

  Lemma subset_1 : forall s s' : t, Subset s s' -> subset s s' = true.
  Proof.
    intros [s1?] [s2?].
    unfold Subset, subset, In, proj1_sig.
    rewrite isSubsetOf_spec by eassumption.
    intuition.
  Qed.
  
  Lemma subset_2 : forall s s' : t, subset s s' = true -> Subset s s'.
  Proof.
    intros [s1?] [s2?].
    unfold Subset, subset, In, proj1_sig.
    rewrite isSubsetOf_spec by eassumption.
    intuition.
  Qed.

  Lemma singleton_1 :
    forall x y : elt, In y (singleton x) -> E.eq x y.
  Proof.
    intros x y.
    unfold In, singleton, proj1_sig.
    rewrite E_eq_zeze.
    eapply singleton_Desc with (ub := None) (lb := None); try reflexivity.
    intros.
    simpl in H1.
    unfold elt in *.
    rewrite H1 in H2.
    rewrite Eq_sym in H2.
    assumption.
  Qed.

  Lemma singleton_2 :
    forall x y : elt, E.eq x y -> In y (singleton x).
  Proof.
    intros x y.
    unfold In, singleton, proj1_sig.
    rewrite E_eq_zeze.
    eapply singleton_Desc with (ub := None) (lb := None); try reflexivity.
    intros.
    unfold elt in *. rewrite H1.
    rewrite Eq_sym.
    assumption.
  Qed.

  Lemma add_1 :
    forall (s : t) (x y : elt), E.eq x y -> In y (add x s).
  Proof.
    intros [s Hs] x y.
    unfold In, add, proj1_sig.
    rewrite E_eq_zeze.
    eapply insert_Desc with (ub := None) (lb := None); try assumption; try reflexivity.
    intros.
    unfold elt in *. rewrite H1.
    rewrite Eq_sym.
    rewrite H2. reflexivity.
  Qed.

  Lemma add_2 : forall (s : t) (x y : elt), In y s -> In y (add x s).
  Proof.
    intros [s Hs] x y.
    unfold In, add, proj1_sig.
    eapply insert_Desc with (ub := None) (lb := None); try assumption; try reflexivity.
    intros.
    unfold elt in *. rewrite H1, H2.
    rewrite orb_true_r.
    reflexivity.
  Qed.

  Lemma add_3 :
    forall (s : t) (x y : elt), ~ E.eq x y -> In y (add x s) -> In y s.
  Proof.
    intros [s Hs] x y.
    unfold In, add, proj1_sig.
    rewrite E_eq_zeze.
    eapply insert_Desc with (ub := None) (lb := None); try assumption; try reflexivity.
    intros.
    unfold elt in *. rewrite H1 in H3.
    rewrite Eq_sym in H3.
    rewrite orb_true_iff in H3. destruct H3 as [H3|H3].
    * congruence.
    * assumption.
  Qed.

  Lemma remove_1 :
    forall (s : t) (x y : elt), E.eq x y -> ~ In y (remove x s).
  Proof.
    intros [s Hs] x y.
    unfold In, remove, proj1_sig.
    rewrite E_eq_zeze.
    eapply delete_Desc with (ub := None) (lb := None); try assumption; try reflexivity.
    intros.
    unfold elt in *.
    rewrite H1.
    rewrite Eq_sym in H2.
    rewrite H2. simpl.
    rewrite andb_false_r.
    congruence.
  Qed.

  Lemma remove_2 :
    forall (s : t) (x y : elt), ~ E.eq x y -> In y s -> In y (remove x s).
  Proof.
    intros [s Hs] x y.
    unfold In, remove, proj1_sig.
    rewrite E_eq_zeze.
    eapply delete_Desc with (ub := None) (lb := None); try assumption; try reflexivity.
    intros.
    unfold elt in *.
    rewrite H1, H3.
    rewrite andb_true_l.
    rewrite Eq_sym in H2.
    rewrite negb_true_iff.
    apply not_true_is_false.
    assumption.
  Qed.

  Lemma remove_3 :
    forall (s : t) (x y : elt), In y (remove x s) -> In y s.
  Proof.
    intros [s Hs] x y.
    unfold In, remove, proj1_sig.
    eapply delete_Desc with (ub := None) (lb := None); try assumption; try reflexivity.
    intros.
    unfold elt in *.
    rewrite H1 in H2.
    rewrite andb_true_iff in H2. intuition.
  Qed.

  Lemma union_1 :
    forall (s s' : t) (x : elt), In x (union s s') -> In x s \/ In x s'.
   Proof.
     intros [s1 Hs1] [s2 Hs2] x.
     unfold In, union, proj1_sig.
    eapply union_Desc with (ub := None) (lb := None); try assumption.
    intros.
    rewrite H1 in H2.
    rewrite orb_true_iff in H2.
    assumption.
  Qed.


  Lemma union_2 :
    forall (s s' : t) (x : elt), In x s -> In x (union s s').
  Proof.
    intros [s1 Hs1] [s2 Hs2] x.
    unfold In, union, proj1_sig.
    eapply union_Desc with (ub := None) (lb := None); try assumption.
    intros.
    rewrite H1 in *.
    rewrite orb_true_iff.
    intuition.
  Qed.
  
  Lemma union_3 :
    forall (s s' : t) (x : elt), In x s' -> In x (union s s').
  Proof.
    intros [s1 Hs1] [s2 Hs2] x.
    unfold In, union, proj1_sig.
    eapply union_Desc with (ub := None) (lb := None); try assumption.
    intros.
    rewrite H1 in *.
    rewrite orb_true_iff.
    intuition.
  Qed.

  Lemma inter_1 : forall (s s' : t) (x : elt),
      In x (inter s s') -> In x s.
  Proof.
    intros [s1 Hs1] [s2 Hs2] x.
    unfold In, inter, proj1_sig.
    eapply intersection_Desc with (ub := None) (lb := None);
      try assumption.
    intros.
    rewrite H1 in *.
    rewrite andb_true_iff in H2.
    intuition.
  Qed.

  Lemma inter_2 : forall (s s' : t) (x : elt),
      In x (inter s s') -> In x s'.
  Proof.
    intros [s1 Hs1] [s2 Hs2] x.
    unfold In, inter, proj1_sig.
    eapply intersection_Desc with (ub := None) (lb := None);
      try assumption.
    intros.
    rewrite H1 in *.
    rewrite andb_true_iff in H2.
    intuition.
  Qed.
  
  Lemma inter_3 : forall (s s' : t) (x : elt),
      In x s -> In x s' -> In x (inter s s').
  Proof.
    intros [s1 Hs1] [s2 Hs2] x.
    unfold In, inter, proj1_sig.
    eapply intersection_Desc with (ub := None) (lb := None);
      try assumption.
    intros.
    rewrite H1, H2, H3.
    intuition.
  Qed.

  Lemma diff_1 :
    forall (s s' : t) (x : elt), In x (diff s s') -> In x s.
  Proof.
    intros [s1 Hs1] [s2 Hs2] x.
    unfold In, diff, proj1_sig.
    eapply difference_Desc with (ub := None) (lb := None);
      try assumption.
    intros.
    rewrite H2 in H3.
    rewrite andb_true_iff in H3.
    intuition.
  Qed.

  Lemma diff_2 :
    forall (s s' : t) (x : elt), In x (diff s s') -> ~ In x s'.
  Proof.
    intros [s1 Hs1] [s2 Hs2] x.
    unfold In, diff, proj1_sig.
    eapply difference_Desc with (ub := None) (lb := None);
      try assumption.
    intros. intro.
    rewrite H2 in H3.
    rewrite andb_true_iff in H3.
    rewrite negb_true_iff in H3.
    intuition congruence.
  Qed.

  Lemma diff_3 :
    forall (s s' : t) (x : elt), In x s -> ~ In x s' -> In x (diff s s').
  Proof.
    intros [s1 Hs1] [s2 Hs2] x.
    unfold In, diff, proj1_sig.
    eapply difference_Desc with (ub := None) (lb := None);
      try assumption.
    intros.
    rewrite H2.
    rewrite andb_true_iff.
    rewrite negb_true_iff.
    intuition try congruence.
    destruct (sem s2 x); congruence.
  Qed.

  Lemma fold_1 :
    forall (s : t) (A : Type) (i : A) (f : elt -> A -> A),
      fold A f s i =
      fold_left (fun (a : A) (e : elt) => f e a) (elements s) i.
  Proof.
    intros [s?] A n k.
    unfold fold, elements, proj1_sig.
    rewrite foldl_spec.
    reflexivity.
  Qed.
  
  Lemma cardinal_1 : forall s : t, cardinal s = length (elements s).
  Proof.
    intros [s?].
    unfold cardinal, elements, proj1_sig.
    erewrite size_spec by eassumption.
    rewrite Nat2Z.id.
    reflexivity.
  Qed.

  Lemma filter_1 :
    forall (s : t) (x : elt) (f : elt -> bool),
      compat_bool E.eq f -> In x (filter f s) -> In x s.
  Proof.
    intros [s?] x f HProper.
    apply compat_bool_Eeq_op_zeze in HProper.
    unfold In, filter, proj1_sig.
    eapply filter_Desc; try eassumption.
    intros s' HB _ Hsem.
    rewrite Hsem.
    rewrite andb_true_iff.
    intuition.
  Qed.

  Lemma filter_2 :
    forall (s : t) (x : elt) (f : elt -> bool),
      compat_bool E.eq f -> In x (filter f s) -> f x = true.
  Proof.
    intros [s?] x f HProper.
    apply compat_bool_Eeq_op_zeze in HProper.
    unfold In, filter, proj1_sig.
    eapply filter_Desc; try eassumption.
    intros s' HB _ Hsem.
    rewrite Hsem.
    rewrite andb_true_iff.
    intuition.
  Qed.

  Lemma filter_3 :
    forall (s : t) (x : elt) (f : elt -> bool),
      compat_bool E.eq f -> In x s -> f x = true -> In x (filter f s).
  Proof.
    intros [s?] x f HProper.
    apply compat_bool_Eeq_op_zeze in HProper.
    unfold In, filter, proj1_sig.
    eapply filter_Desc; try eassumption.
    intros s' HB _ Hsem.
    rewrite Hsem.
    rewrite andb_true_iff.
    intuition.
  Qed.

  Lemma partition_1 :
    forall (s : t) (f : elt -> bool),
      compat_bool E.eq f -> Equal (fst (partition f s)) (filter f s).
  Proof.
    intros [s?] f HProper.
    apply compat_bool_Eeq_op_zeze in HProper.
    unfold Equal, In, filter, partition, fst, proj1_sig.
    eapply filter_Desc; try eassumption.
    intros s' HB _ Hsem.
    eapply partition_spec; try eassumption.
    intros s1 s2 [HD1 HD2].
    eapply HD1; intros s1' HBs1' _ Hsems1'.
    intro.
    rewrite Hsem, Hsems1'.
    reflexivity.
  Qed.
  
  Lemma compat_bool_negb:
    forall A R (f : A -> bool), compat_bool R f -> compat_bool R (fun x => negb (f x)).
  Proof. intros. intros x y HR. f_equal. apply H. assumption. Qed.

  Lemma partition_2 :
    forall (s : t) (f : elt -> bool),
      compat_bool E.eq f ->
      Equal (snd (partition f s)) (filter (fun x : elt => negb (f x)) s).
  Proof.
    intros [s?] f HProper.
    apply compat_bool_Eeq_op_zeze in HProper.
    pose proof (compat_bool_negb _ _ _ HProper).
    unfold Equal, In, filter, partition, snd, proj1_sig.
    eapply filter_Desc; try eassumption.
    intros s' HB _ Hsem.
    eapply partition_spec; try eassumption.
    intros s1 s2 [HD1 HD2].
    eapply HD2; intros s2' HBs2' _ Hsems2'.
    intro.
    rewrite Hsem, Hsems2'.
    reflexivity.
  Qed.

  Lemma elements_1 :
    forall (s : t) (x : elt), In x s -> InA E.eq x (elements s).
  Proof.
    intros [s?] x H.
    unfold In, elements, proj1_sig in *.
    rewrite InA_Eeq_elem in *.
    erewrite toList_sem in H by eassumption.
    assumption.
  Qed.

  Lemma elements_2 :
    forall (s : t) (x : elt), InA E.eq x (elements s) -> In x s.
  Proof.
    intros [s?] x H.
    unfold In, elements, proj1_sig in *.
    rewrite InA_Eeq_elem in *.
    erewrite toList_sem in * by eassumption.
    assumption.
  Qed.

  Lemma elements_3w : forall s : t, NoDupA E.eq (elements s).
  Proof.
    intros [s?].
    unfold elements, proj1_sig.
    apply OrdFacts.Sort_NoDup.
    apply StronglySorted_Sorted.
    assert (StronglySorted lt (toList s)) by (eapply to_List_sorted; eassumption).
    (* Here we just replace E.lt with lt *)
    induction H.
    * apply SSorted_nil.    
    * apply SSorted_cons; try assumption.
      clear IHStronglySorted H.
      induction H0.
      - constructor.
      - constructor; try assumption.
        rewrite E_lt_zl. assumption.
  Qed.

(**
  These portions of the [FMapInterface] have no counterpart in the [IntSet] interface.
  We implement them generically.
  *)

  Definition For_all (P : elt -> Prop) s := forall x, In x s -> P x.
  Definition Exists (P : elt -> Prop) s := exists x, In x s /\ P x.

  Definition for_all : (elt -> bool) -> t -> bool :=
    fun P s => forallb P (elements s).
  Definition exists_ : (elt -> bool) -> t -> bool :=
    fun P s => existsb P (elements s).

  Lemma for_all_1 :
    forall (s : t) (f : elt -> bool),
    compat_bool E.eq f ->
    For_all (fun x : elt => f x = true) s -> for_all f s = true.
  Proof.
    intros.
    unfold For_all, for_all in *.
    rewrite forallb_forall.
    intros. apply H0.
    apply elements_2.
    apply OrdFacts.ListIn_In.
    assumption.
  Qed.

  Lemma for_all_2 :
    forall (s : t) (f : elt -> bool),
    compat_bool E.eq f ->
    for_all f s = true -> For_all (fun x : elt => f x = true) s.
  Proof.
    intros.
    unfold For_all, for_all in *.
    rewrite forallb_forall in H0.
    intros.
    apply elements_1 in H1.
    rewrite InA_alt in H1.
    destruct H1 as [?[??]].
    assert (f x0 = true) by (apply H0; assumption).
    unfold compat_bool in H.
    setoid_rewrite H1.
    assumption.
  Qed.

  Lemma exists_1 :
    forall (s : t) (f : elt -> bool),
    compat_bool E.eq f ->
    Exists (fun x : elt => f x = true) s -> exists_ f s = true.
  Proof.
    intros.
    unfold Exists, exists_ in *.
    rewrite existsb_exists.
    destruct H0 as [x[??]].
    apply elements_1 in H0.
    rewrite InA_alt in H0.
    destruct H0 as [?[??]].
    exists x0.
    split; auto.
    unfold compat_bool in H.
    setoid_rewrite <- H0.
    assumption.
  Qed.

  Lemma exists_2 :
    forall (s : t) (f : elt -> bool),
    compat_bool E.eq f ->
    exists_ f s = true -> Exists (fun x : elt => f x = true) s.
  Proof.
    intros.
    unfold Exists, exists_ in *.
    rewrite existsb_exists in H0.
    destruct H0 as [x[??]].
    exists x.
    split; auto.
    apply elements_2.
    apply OrdFacts.ListIn_In.
    assumption.
  Qed.
  
 (** One could implement [choose] with [minView]. We currenlty do not
  translate [minView], because of a call to [error] in a branch that is inaccessible
  in well-formed trees. Stretch goal: translate that and use it here.
  *)

  Definition choose : t -> option elt :=
    fun s => match elements s with
                | nil => None
                | x :: _ => Some x
              end.


  Lemma choose_1 :
    forall (s : t) (x : elt), choose s = Some x -> In x s.
  Proof.
    intros.
    unfold choose in *.
    destruct (elements s) eqn:?; try congruence.
    inversion H; subst.
    apply elements_2.
    rewrite Heql.
    left.
    reflexivity.
  Qed.

  Lemma choose_2 : forall s : t, choose s = None -> Empty s.
  Proof.
    intros.
    unfold choose in *.
    destruct (elements s) eqn:?; try congruence.
    intros x ?.
    apply elements_1 in H0.
    rewrite Heql in H0.
    inversion H0.
  Qed.


End SetWSfun.

(** Type classes. Because a [Set_ e] is only useful if it well-formed, we instantiate
the law classes with a subset type. *)

Require Import Proofs.GHC.Base.

Section TypeClassLaws.
Context {e : Type} {HEq : Eq_ e} {HOrd : Ord e} {HEqLaws : EqLaws e}  {HOrdLaws : OrdLaws e}.

Definition WFSet := {s: Set_ e | Bounded s None None }.

Program Instance Eq_Set_WF : Eq_ WFSet := fun _ k => k
  {| op_zeze____ := @op_zeze__ (Set_ e) _
   ; op_zsze____ := @op_zsze__ (Set_ e) _
  |}.

Program Instance Ord_Set_WF : Ord WFSet := fun _ k => k
  {| op_zlze____ := @op_zlze__ (Set_ e) _ _
   ; op_zgze____ := @op_zgze__ (Set_ e) _ _
   ; op_zl____ := @op_zl__ (Set_ e) _ _
   ; op_zg____ := @op_zg__ (Set_ e) _ _
   ; compare__ := @compare (Set_ e) _ _
   ; min__ := @min (Set_ e) _ _
   ; max__ := @max (Set_ e) _ _
  |}.
Next Obligation.
  destruct x as [s1 HB1], x0 as [s2 HB2]. simpl.
  unfold max, Ord__Set_, max__, Internal.Ord__Set__max.
  destruct (Internal.Ord__Set__op_zlze__ _ _); assumption.
Qed.
Next Obligation.
  destruct x as [s1 HB1], x0 as [s2 HB2]. simpl.
  unfold min, Ord__Set_, min__, Internal.Ord__Set__min.
  destruct (Internal.Ord__Set__op_zlze__ _ _); assumption.
Qed.


From mathcomp Require Import ssreflect ssrbool.
Set Bullet Behavior "Strict Subproofs".

Local Ltac unfold_WFSet_Eq :=
  unfold "_==_", "_/=_", Eq_Set_WF => /=;
  unfold "_==_", "_/=_", Eq___Set_ => /=;
  unfold Data.Set.Internal.Eq___Set__op_zsze__, Data.Set.Internal.Eq___Set__op_zeze__ => /=.

Local Ltac unfold_WFSet_Ord :=
  unfold "_<=_", "_<_", "_>=_", "_>_", compare, Ord_Set_WF => /=;
  unfold "_<=_", "_<_", "_>=_", "_>_", compare, Ord__Set_ => /=;
  unfold Data.Set.Internal.Ord__Set__op_zlze__, Data.Set.Internal.Ord__Set__op_zl__,
         Data.Set.Internal.Ord__Set__op_zgze__, Data.Set.Internal.Ord__Set__op_zg__,
         Data.Set.Internal.Ord__Set__compare => /=.

Global Instance EqLaws_Set : EqLaws WFSet.
Proof.
  constructor.
  - by move=> x; unfold_WFSet_Eq; rewrite !Eq_refl.
  - by move=> x y; unfold_WFSet_Eq; f_equal; rewrite Eq_sym.
  - move=> x y z; unfold_WFSet_Eq=> /andP [size_xy list_xy] /andP [size_yz list_yz].
    by apply/andP; split; eapply Eq_trans; eassumption.
  - by move=> x y; unfold_WFSet_Eq; rewrite negbK.
Qed.

Lemma compare_neq_gt_iff_le {t} `{OrdLaws t} (l1 l2 : t) :
  (compare l1 l2 /= Gt = true) <-> l1 <= l2.
Proof.
  rewrite Neq_inv negb_true_iff.
  case LE: (_ <= _) => //=.
  - split=> [// | _].
    by apply/Eq_eq; rewrite Ord_compare_Gt LE.
  - by move: LE; rewrite -Ord_compare_Gt => ->.
Qed.

Lemma WFSet_eq_size_length (a : WFSet) :
  Data.Set.Internal.size (proj1_sig a) = Z.of_nat (Datatypes.length (toAscList (proj1_sig a))).
Proof.
  move: a => [a WFa]; unfold "==", Eq_Set_WF => /=.
  rewrite size_size; erewrite size_spec => //; exact WFa.
Qed.

Local Ltac hideToAscList a :=
  let la := fresh "l" a in
  let EQ := fresh "EQ"  in
  remember (toAscList (proj1_sig a)) as la eqn:EQ; try clear a EQ.

Global Instance OrdLaws_Set : OrdLaws WFSet.
Proof.
  constructor; unfold_WFSet_Eq; unfold_WFSet_Ord.
  - move=> a b; rewrite !compare_neq_gt_iff_le => LEab LEba.
    generalize (Ord_antisym _ _ LEab LEba) => EQab.
    apply/andP; split=> //.
    rewrite !WFSet_eq_size_length; apply/Eq_eq.
    rewrite Nat2Z.inj_iff; apply eqlist_length, EQab.
  - move=> a b c; rewrite !compare_neq_gt_iff_le; unfold is_true; order (list e).
  - move=> a b; rewrite !compare_neq_gt_iff_le; apply Ord_total.
  - move=> a b; rewrite Ord_compare_Lt Neq_inv negb_false_iff.
    split=> [? | /Eq_eq]; first apply/Eq_eq; rewrite Ord_compare_Gt; order (list e).
  - move=> a b; rewrite Ord_compare_Eq.
    split=> [EQ | /andP [LIST EQ]]; rewrite EQ => //=.
    rewrite andbT !WFSet_eq_size_length; apply/Eq_eq.
    rewrite Nat2Z.inj_iff; apply eqlist_length, EQ.
  - move=> a b; rewrite Ord_compare_Gt Neq_inv negb_false_iff.
    split=> [? | /Eq_eq]; first apply/Eq_eq; rewrite Ord_compare_Gt; order (list e).
  - by move=> a b; rewrite Neq_inv negbK compare_flip; case: (compare _ _).
  - by move=> a b; rewrite !Neq_inv compare_flip; case: (compare _ _).
  - by move=> a b; rewrite Neq_inv negbK compare_flip; case: (compare _ _).
Qed.

End TypeClassLaws.
