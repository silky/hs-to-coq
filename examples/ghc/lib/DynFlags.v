(* Default settings (from HsToCoq.Coq.Preamble) *)

Generalizable All Variables.

Unset Implicit Arguments.
Set Maximal Implicit Insertion.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Require Coq.Program.Tactics.
Require Coq.Program.Wf.

(* Converted imports: *)

Require Data.Either.
Require GHC.Base.
Require GHC.Char.
Require GHC.Num.
Require Module.
Require SrcLoc.

(* Converted type declarations: *)

Inductive Way : Type := WayCustom : GHC.Base.String -> Way
                     |  WayThreaded : Way
                     |  WayDebug : Way
                     |  WayProf : Way
                     |  WayEventLog : Way
                     |  WayDyn : Way.

Inductive WarningFlag : Type := Opt_WarnDuplicateExports : WarningFlag
                             |  Opt_WarnDuplicateConstraints : WarningFlag
                             |  Opt_WarnRedundantConstraints : WarningFlag
                             |  Opt_WarnHiShadows : WarningFlag
                             |  Opt_WarnImplicitPrelude : WarningFlag
                             |  Opt_WarnIncompletePatterns : WarningFlag
                             |  Opt_WarnIncompleteUniPatterns : WarningFlag
                             |  Opt_WarnIncompletePatternsRecUpd : WarningFlag
                             |  Opt_WarnOverflowedLiterals : WarningFlag
                             |  Opt_WarnEmptyEnumerations : WarningFlag
                             |  Opt_WarnMissingFields : WarningFlag
                             |  Opt_WarnMissingImportList : WarningFlag
                             |  Opt_WarnMissingMethods : WarningFlag
                             |  Opt_WarnMissingSignatures : WarningFlag
                             |  Opt_WarnMissingLocalSignatures : WarningFlag
                             |  Opt_WarnNameShadowing : WarningFlag
                             |  Opt_WarnOverlappingPatterns : WarningFlag
                             |  Opt_WarnTypeDefaults : WarningFlag
                             |  Opt_WarnMonomorphism : WarningFlag
                             |  Opt_WarnUnusedTopBinds : WarningFlag
                             |  Opt_WarnUnusedLocalBinds : WarningFlag
                             |  Opt_WarnUnusedPatternBinds : WarningFlag
                             |  Opt_WarnUnusedImports : WarningFlag
                             |  Opt_WarnUnusedMatches : WarningFlag
                             |  Opt_WarnUnusedTypePatterns : WarningFlag
                             |  Opt_WarnUnusedForalls : WarningFlag
                             |  Opt_WarnContextQuantification : WarningFlag
                             |  Opt_WarnWarningsDeprecations : WarningFlag
                             |  Opt_WarnDeprecatedFlags : WarningFlag
                             |  Opt_WarnAMP : WarningFlag
                             |  Opt_WarnMissingMonadFailInstances : WarningFlag
                             |  Opt_WarnSemigroup : WarningFlag
                             |  Opt_WarnDodgyExports : WarningFlag
                             |  Opt_WarnDodgyImports : WarningFlag
                             |  Opt_WarnOrphans : WarningFlag
                             |  Opt_WarnAutoOrphans : WarningFlag
                             |  Opt_WarnIdentities : WarningFlag
                             |  Opt_WarnTabs : WarningFlag
                             |  Opt_WarnUnrecognisedPragmas : WarningFlag
                             |  Opt_WarnDodgyForeignImports : WarningFlag
                             |  Opt_WarnUnusedDoBind : WarningFlag
                             |  Opt_WarnWrongDoBind : WarningFlag
                             |  Opt_WarnAlternativeLayoutRuleTransitional : WarningFlag
                             |  Opt_WarnUnsafe : WarningFlag
                             |  Opt_WarnSafe : WarningFlag
                             |  Opt_WarnTrustworthySafe : WarningFlag
                             |  Opt_WarnMissedSpecs : WarningFlag
                             |  Opt_WarnAllMissedSpecs : WarningFlag
                             |  Opt_WarnUnsupportedCallingConventions : WarningFlag
                             |  Opt_WarnUnsupportedLlvmVersion : WarningFlag
                             |  Opt_WarnInlineRuleShadowing : WarningFlag
                             |  Opt_WarnTypedHoles : WarningFlag
                             |  Opt_WarnPartialTypeSignatures : WarningFlag
                             |  Opt_WarnMissingExportedSignatures : WarningFlag
                             |  Opt_WarnUntickedPromotedConstructors : WarningFlag
                             |  Opt_WarnDerivingTypeable : WarningFlag
                             |  Opt_WarnDeferredTypeErrors : WarningFlag
                             |  Opt_WarnDeferredOutOfScopeVariables : WarningFlag
                             |  Opt_WarnNonCanonicalMonadInstances : WarningFlag
                             |  Opt_WarnNonCanonicalMonadFailInstances : WarningFlag
                             |  Opt_WarnNonCanonicalMonoidInstances : WarningFlag
                             |  Opt_WarnMissingPatternSynonymSignatures : WarningFlag
                             |  Opt_WarnUnrecognisedWarningFlags : WarningFlag.

Inductive WarnReason : Type := NoReason : WarnReason
                            |  Reason : WarningFlag -> WarnReason.

Definition TurnOnFlag :=
  bool%type.

Inductive TrustFlag : Type := TrustPackage : GHC.Base.String -> TrustFlag
                           |  DistrustPackage : GHC.Base.String -> TrustFlag.

Inductive SseVersion : Type := SSE1 : SseVersion
                            |  SSE2 : SseVersion
                            |  SSE3 : SseVersion
                            |  SSE4 : SseVersion
                            |  SSE42 : SseVersion.

Definition SigOf :=
  (Module.ModuleNameEnv Module.Module)%type.

Inductive Settings : Type := Mk_Settings.

Inductive SafeHaskellMode : Type := Sf_None : SafeHaskellMode
                                 |  Sf_Unsafe : SafeHaskellMode
                                 |  Sf_Trustworthy : SafeHaskellMode
                                 |  Sf_Safe : SafeHaskellMode.

Inductive RtsOptsEnabled : Type := RtsOptsNone : RtsOptsEnabled
                                |  RtsOptsSafeOnly : RtsOptsEnabled
                                |  RtsOptsAll : RtsOptsEnabled.

Inductive ProfAuto : Type := NoProfAuto : ProfAuto
                          |  ProfAutoAll : ProfAuto
                          |  ProfAutoTop : ProfAuto
                          |  ProfAutoExports : ProfAuto
                          |  ProfAutoCalls : ProfAuto.

Inductive PkgConfRef : Type := GlobalPkgConf : PkgConfRef
                            |  UserPkgConf : PkgConfRef
                            |  PkgConfFile : GHC.Base.String -> PkgConfRef.

Inductive PackageArg : Type := Mk_PackageArg : GHC.Base.String -> PackageArg
                            |  UnitIdArg : GHC.Base.String -> PackageArg.

Inductive Option : Type := FileOption
                          : GHC.Base.String -> GHC.Base.String -> Option
                        |  Mk_Option : GHC.Base.String -> Option.

Inductive OnOff a : Type := On : a -> OnOff a
                         |  Off : a -> OnOff a.

Inductive ModRenaming : Type := Mk_ModRenaming : bool -> list (Module.ModuleName
                                                              * Module.ModuleName)%type -> ModRenaming.

Inductive PackageFlag : Type := ExposePackage
                               : GHC.Base.String -> PackageArg -> ModRenaming -> PackageFlag
                             |  HidePackage : GHC.Base.String -> PackageFlag.

Inductive LinkerInfo : Type := GnuLD : list Option -> LinkerInfo
                            |  GnuGold : list Option -> LinkerInfo
                            |  DarwinLD : list Option -> LinkerInfo
                            |  SolarisLD : list Option -> LinkerInfo
                            |  AixLD : list Option -> LinkerInfo
                            |  UnknownLD : LinkerInfo.

Inductive Language : Type := Haskell98 : Language
                          |  Haskell2010 : Language.

Inductive IgnorePackageFlag : Type := IgnorePackage
                                     : GHC.Base.String -> IgnorePackageFlag.

Inductive HscTarget : Type := HscC : HscTarget
                           |  HscAsm : HscTarget
                           |  HscLlvm : HscTarget
                           |  HscInterpreted : HscTarget
                           |  HscNothing : HscTarget.

Inductive GhcMode : Type := CompManager : GhcMode
                         |  OneShot : GhcMode
                         |  MkDepend : GhcMode.

Inductive GhcLink : Type := NoLink : GhcLink
                         |  LinkBinary : GhcLink
                         |  LinkInMemory : GhcLink
                         |  LinkDynLib : GhcLink
                         |  LinkStaticLib : GhcLink.

Inductive GeneralFlag : Type := Opt_DumpToFile : GeneralFlag
                             |  Opt_D_faststring_stats : GeneralFlag
                             |  Opt_D_dump_minimal_imports : GeneralFlag
                             |  Opt_DoCoreLinting : GeneralFlag
                             |  Opt_DoStgLinting : GeneralFlag
                             |  Opt_DoCmmLinting : GeneralFlag
                             |  Opt_DoAsmLinting : GeneralFlag
                             |  Opt_DoAnnotationLinting : GeneralFlag
                             |  Opt_NoLlvmMangler : GeneralFlag
                             |  Opt_WarnIsError : GeneralFlag
                             |  Opt_ShowWarnGroups : GeneralFlag
                             |  Opt_PrintExplicitForalls : GeneralFlag
                             |  Opt_PrintExplicitKinds : GeneralFlag
                             |  Opt_PrintExplicitCoercions : GeneralFlag
                             |  Opt_PrintExplicitRuntimeReps : GeneralFlag
                             |  Opt_PrintEqualityRelations : GeneralFlag
                             |  Opt_PrintUnicodeSyntax : GeneralFlag
                             |  Opt_PrintExpandedSynonyms : GeneralFlag
                             |  Opt_PrintPotentialInstances : GeneralFlag
                             |  Opt_PrintTypecheckerElaboration : GeneralFlag
                             |  Opt_CallArity : GeneralFlag
                             |  Opt_Strictness : GeneralFlag
                             |  Opt_LateDmdAnal : GeneralFlag
                             |  Opt_KillAbsence : GeneralFlag
                             |  Opt_KillOneShot : GeneralFlag
                             |  Opt_FullLaziness : GeneralFlag
                             |  Opt_FloatIn : GeneralFlag
                             |  Opt_Specialise : GeneralFlag
                             |  Opt_SpecialiseAggressively : GeneralFlag
                             |  Opt_CrossModuleSpecialise : GeneralFlag
                             |  Opt_StaticArgumentTransformation : GeneralFlag
                             |  Opt_CSE : GeneralFlag
                             |  Opt_LiberateCase : GeneralFlag
                             |  Opt_SpecConstr : GeneralFlag
                             |  Opt_DoLambdaEtaExpansion : GeneralFlag
                             |  Opt_IgnoreAsserts : GeneralFlag
                             |  Opt_DoEtaReduction : GeneralFlag
                             |  Opt_CaseMerge : GeneralFlag
                             |  Opt_UnboxStrictFields : GeneralFlag
                             |  Opt_UnboxSmallStrictFields : GeneralFlag
                             |  Opt_DictsCheap : GeneralFlag
                             |  Opt_EnableRewriteRules : GeneralFlag
                             |  Opt_Vectorise : GeneralFlag
                             |  Opt_VectorisationAvoidance : GeneralFlag
                             |  Opt_RegsGraph : GeneralFlag
                             |  Opt_RegsIterative : GeneralFlag
                             |  Opt_PedanticBottoms : GeneralFlag
                             |  Opt_LlvmTBAA : GeneralFlag
                             |  Opt_LlvmPassVectorsInRegisters : GeneralFlag
                             |  Opt_IrrefutableTuples : GeneralFlag
                             |  Opt_CmmSink : GeneralFlag
                             |  Opt_CmmElimCommonBlocks : GeneralFlag
                             |  Opt_OmitYields : GeneralFlag
                             |  Opt_FunToThunk : GeneralFlag
                             |  Opt_DictsStrict : GeneralFlag
                             |  Opt_DmdTxDictSel : GeneralFlag
                             |  Opt_Loopification : GeneralFlag
                             |  Opt_CprAnal : GeneralFlag
                             |  Opt_WorkerWrapper : GeneralFlag
                             |  Opt_IgnoreInterfacePragmas : GeneralFlag
                             |  Opt_OmitInterfacePragmas : GeneralFlag
                             |  Opt_ExposeAllUnfoldings : GeneralFlag
                             |  Opt_WriteInterface : GeneralFlag
                             |  Opt_AutoSccsOnIndividualCafs : GeneralFlag
                             |  Opt_ProfCountEntries : GeneralFlag
                             |  Opt_Pp : GeneralFlag
                             |  Opt_ForceRecomp : GeneralFlag
                             |  Opt_ExcessPrecision : GeneralFlag
                             |  Opt_EagerBlackHoling : GeneralFlag
                             |  Opt_NoHsMain : GeneralFlag
                             |  Opt_SplitObjs : GeneralFlag
                             |  Opt_SplitSections : GeneralFlag
                             |  Opt_StgStats : GeneralFlag
                             |  Opt_HideAllPackages : GeneralFlag
                             |  Opt_HideAllPluginPackages : GeneralFlag
                             |  Opt_PrintBindResult : GeneralFlag
                             |  Opt_Haddock : GeneralFlag
                             |  Opt_HaddockOptions : GeneralFlag
                             |  Opt_BreakOnException : GeneralFlag
                             |  Opt_BreakOnError : GeneralFlag
                             |  Opt_PrintEvldWithShow : GeneralFlag
                             |  Opt_PrintBindContents : GeneralFlag
                             |  Opt_GenManifest : GeneralFlag
                             |  Opt_EmbedManifest : GeneralFlag
                             |  Opt_SharedImplib : GeneralFlag
                             |  Opt_BuildingCabalPackage : GeneralFlag
                             |  Opt_IgnoreDotGhci : GeneralFlag
                             |  Opt_GhciSandbox : GeneralFlag
                             |  Opt_GhciHistory : GeneralFlag
                             |  Opt_HelpfulErrors : GeneralFlag
                             |  Opt_DeferTypeErrors : GeneralFlag
                             |  Opt_DeferTypedHoles : GeneralFlag
                             |  Opt_DeferOutOfScopeVariables : GeneralFlag
                             |  Opt_PIC : GeneralFlag
                             |  Opt_SccProfilingOn : GeneralFlag
                             |  Opt_Ticky : GeneralFlag
                             |  Opt_Ticky_Allocd : GeneralFlag
                             |  Opt_Ticky_LNE : GeneralFlag
                             |  Opt_Ticky_Dyn_Thunk : GeneralFlag
                             |  Opt_RPath : GeneralFlag
                             |  Opt_RelativeDynlibPaths : GeneralFlag
                             |  Opt_Hpc : GeneralFlag
                             |  Opt_FlatCache : GeneralFlag
                             |  Opt_ExternalInterpreter : GeneralFlag
                             |  Opt_VersionMacros : GeneralFlag
                             |  Opt_OptimalApplicativeDo : GeneralFlag
                             |  Opt_SimplPreInlining : GeneralFlag
                             |  Opt_ErrorSpans : GeneralFlag
                             |  Opt_PprCaseAsLet : GeneralFlag
                             |  Opt_PprShowTicks : GeneralFlag
                             |  Opt_SuppressCoercions : GeneralFlag
                             |  Opt_SuppressVarKinds : GeneralFlag
                             |  Opt_SuppressModulePrefixes : GeneralFlag
                             |  Opt_SuppressTypeApplications : GeneralFlag
                             |  Opt_SuppressIdInfo : GeneralFlag
                             |  Opt_SuppressUnfoldings : GeneralFlag
                             |  Opt_SuppressTypeSignatures : GeneralFlag
                             |  Opt_SuppressUniques : GeneralFlag
                             |  Opt_AutoLinkPackages : GeneralFlag
                             |  Opt_ImplicitImportQualified : GeneralFlag
                             |  Opt_KeepHiDiffs : GeneralFlag
                             |  Opt_KeepHcFiles : GeneralFlag
                             |  Opt_KeepSFiles : GeneralFlag
                             |  Opt_KeepTmpFiles : GeneralFlag
                             |  Opt_KeepRawTokenStream : GeneralFlag
                             |  Opt_KeepLlvmFiles : GeneralFlag
                             |  Opt_BuildDynamicToo : GeneralFlag
                             |  Opt_DistrustAllPackages : GeneralFlag
                             |  Opt_PackageTrust : GeneralFlag.

Inductive FlushOut : Type := Mk_FlushOut.

Inductive FlushErr : Type := Mk_FlushErr.

Inductive FlagSpec (flag : Type) : Type := Mk_FlagSpec.

Inductive DynLibLoader : Type := Deployable : DynLibLoader
                              |  SystemDependent : DynLibLoader.

Inductive DynFlags : Type := Mk_DynFlags.

Record HasDynFlags__Dict m := HasDynFlags__Dict_Build {
  getDynFlags__ : m DynFlags }.

Definition HasDynFlags m :=
  forall r, (HasDynFlags__Dict m -> r) -> r.

Existing Class HasDynFlags.

Definition getDynFlags `{g : HasDynFlags m} : m DynFlags :=
  g _ (getDynFlags__ m).

Inductive DumpFlag : Type := Opt_D_dump_cmm : DumpFlag
                          |  Opt_D_dump_cmm_raw : DumpFlag
                          |  Opt_D_dump_cmm_cfg : DumpFlag
                          |  Opt_D_dump_cmm_cbe : DumpFlag
                          |  Opt_D_dump_cmm_switch : DumpFlag
                          |  Opt_D_dump_cmm_proc : DumpFlag
                          |  Opt_D_dump_cmm_sink : DumpFlag
                          |  Opt_D_dump_cmm_sp : DumpFlag
                          |  Opt_D_dump_cmm_procmap : DumpFlag
                          |  Opt_D_dump_cmm_split : DumpFlag
                          |  Opt_D_dump_cmm_info : DumpFlag
                          |  Opt_D_dump_cmm_cps : DumpFlag
                          |  Opt_D_dump_asm : DumpFlag
                          |  Opt_D_dump_asm_native : DumpFlag
                          |  Opt_D_dump_asm_liveness : DumpFlag
                          |  Opt_D_dump_asm_regalloc : DumpFlag
                          |  Opt_D_dump_asm_regalloc_stages : DumpFlag
                          |  Opt_D_dump_asm_conflicts : DumpFlag
                          |  Opt_D_dump_asm_stats : DumpFlag
                          |  Opt_D_dump_asm_expanded : DumpFlag
                          |  Opt_D_dump_llvm : DumpFlag
                          |  Opt_D_dump_core_stats : DumpFlag
                          |  Opt_D_dump_deriv : DumpFlag
                          |  Opt_D_dump_ds : DumpFlag
                          |  Opt_D_dump_foreign : DumpFlag
                          |  Opt_D_dump_inlinings : DumpFlag
                          |  Opt_D_dump_rule_firings : DumpFlag
                          |  Opt_D_dump_rule_rewrites : DumpFlag
                          |  Opt_D_dump_simpl_trace : DumpFlag
                          |  Opt_D_dump_occur_anal : DumpFlag
                          |  Opt_D_dump_parsed : DumpFlag
                          |  Opt_D_dump_rn : DumpFlag
                          |  Opt_D_dump_simpl : DumpFlag
                          |  Opt_D_dump_simpl_iterations : DumpFlag
                          |  Opt_D_dump_spec : DumpFlag
                          |  Opt_D_dump_prep : DumpFlag
                          |  Opt_D_dump_stg : DumpFlag
                          |  Opt_D_dump_call_arity : DumpFlag
                          |  Opt_D_dump_stranal : DumpFlag
                          |  Opt_D_dump_str_signatures : DumpFlag
                          |  Opt_D_dump_tc : DumpFlag
                          |  Opt_D_dump_types : DumpFlag
                          |  Opt_D_dump_rules : DumpFlag
                          |  Opt_D_dump_cse : DumpFlag
                          |  Opt_D_dump_worker_wrapper : DumpFlag
                          |  Opt_D_dump_rn_trace : DumpFlag
                          |  Opt_D_dump_rn_stats : DumpFlag
                          |  Opt_D_dump_opt_cmm : DumpFlag
                          |  Opt_D_dump_simpl_stats : DumpFlag
                          |  Opt_D_dump_cs_trace : DumpFlag
                          |  Opt_D_dump_tc_trace : DumpFlag
                          |  Opt_D_dump_if_trace : DumpFlag
                          |  Opt_D_dump_vt_trace : DumpFlag
                          |  Opt_D_dump_splices : DumpFlag
                          |  Opt_D_th_dec_file : DumpFlag
                          |  Opt_D_dump_BCOs : DumpFlag
                          |  Opt_D_dump_vect : DumpFlag
                          |  Opt_D_dump_ticked : DumpFlag
                          |  Opt_D_dump_rtti : DumpFlag
                          |  Opt_D_source_stats : DumpFlag
                          |  Opt_D_verbose_stg2stg : DumpFlag
                          |  Opt_D_dump_hi : DumpFlag
                          |  Opt_D_dump_hi_diffs : DumpFlag
                          |  Opt_D_dump_mod_cycles : DumpFlag
                          |  Opt_D_dump_mod_map : DumpFlag
                          |  Opt_D_dump_view_pattern_commoning : DumpFlag
                          |  Opt_D_verbose_core2core : DumpFlag
                          |  Opt_D_dump_debug : DumpFlag.

Inductive Deprecation : Type := Deprecated : Deprecation
                             |  NotDeprecated : Deprecation.

Record ContainsDynFlags__Dict t := ContainsDynFlags__Dict_Build {
  extractDynFlags__ : t -> DynFlags }.

Definition ContainsDynFlags t :=
  forall r, (ContainsDynFlags__Dict t -> r) -> r.

Existing Class ContainsDynFlags.

Definition extractDynFlags `{g : ContainsDynFlags t} : t -> DynFlags :=
  g _ (extractDynFlags__ t).

Inductive CompilerInfo : Type := GCC : CompilerInfo
                              |  Clang : CompilerInfo
                              |  AppleClang : CompilerInfo
                              |  AppleClang51 : CompilerInfo
                              |  UnknownCC : CompilerInfo.

Arguments On {_} _.

Arguments Off {_} _.

Definition modRenamingWithImplicit (arg_0__ : ModRenaming) :=
  match arg_0__ with
    | Mk_ModRenaming modRenamingWithImplicit _ => modRenamingWithImplicit
  end.

Definition modRenamings (arg_1__ : ModRenaming) :=
  match arg_1__ with
    | Mk_ModRenaming _ modRenamings => modRenamings
  end.
(* Midamble *)

Instance Unpeel_IgnorePackageFlag : Prim.Unpeel IgnorePackageFlag GHC.Base.String :=
  Prim.Build_Unpeel _ _ (fun x => match x with | IgnorePackage y => y end) IgnorePackage.

(* Converted value declarations: *)

Instance Eq___CompilerInfo : GHC.Base.Eq_ CompilerInfo := {}.
Proof.
Admitted.

Instance Eq___LinkerInfo : GHC.Base.Eq_ LinkerInfo := {}.
Proof.
Admitted.

Instance Eq___SseVersion : GHC.Base.Eq_ SseVersion := {}.
Proof.
Admitted.

Instance Eq___Option : GHC.Base.Eq_ Option := {}.
Proof.
Admitted.

Instance Eq___Way : GHC.Base.Eq_ Way := {}.
Proof.
Admitted.

Instance Eq___DynLibLoader : GHC.Base.Eq_ DynLibLoader := {}.
Proof.
Admitted.

Instance Eq___PackageFlag : GHC.Base.Eq_ PackageFlag := {}.
Proof.
Admitted.

Instance Eq___TrustFlag : GHC.Base.Eq_ TrustFlag := {}.
Proof.
Admitted.

Instance Eq___IgnorePackageFlag : GHC.Base.Eq_ IgnorePackageFlag := {}.
Proof.
Admitted.

Instance Eq___PackageArg : GHC.Base.Eq_ PackageArg := {}.
Proof.
Admitted.

Instance Eq___ModRenaming : GHC.Base.Eq_ ModRenaming := {}.
Proof.
Admitted.

Instance Eq___GhcLink : GHC.Base.Eq_ GhcLink := {}.
Proof.
Admitted.

Instance Eq___GhcMode : GHC.Base.Eq_ GhcMode := {}.
Proof.
Admitted.

Instance Eq___HscTarget : GHC.Base.Eq_ HscTarget := {}.
Proof.
Admitted.

Instance Eq___ProfAuto : GHC.Base.Eq_ ProfAuto := {}.
Proof.
Admitted.

Instance Eq___SafeHaskellMode : GHC.Base.Eq_ SafeHaskellMode := {}.
Proof.
Admitted.

Axiom getSigOf : DynFlags -> Module.ModuleName -> option Module.Module.

Axiom isSse2Enabled : DynFlags -> bool.

Axiom isSseEnabled : DynFlags -> bool.

(* parseDynamicFilePragma skipped *)

(* parseDynamicFlagsCmdLine skipped *)

(* parseDynamicFlagsFull skipped *)

Axiom makeDynFlagsConsistent : DynFlags -> (DynFlags * list (SrcLoc.Located
                                                            GHC.Base.String))%type.

Axiom tARGET_MAX_WORD : DynFlags -> GHC.Num.Integer.

Axiom tARGET_MAX_INT : DynFlags -> GHC.Num.Integer.

Axiom tARGET_MIN_INT : DynFlags -> GHC.Num.Integer.

Axiom compilerInfo : DynFlags -> list (GHC.Base.String * GHC.Base.String)%type.

Axiom picCCOpts : DynFlags -> list GHC.Base.String.

(* flagsDynamic skipped *)

Axiom flagsForCompletion : bool -> list GHC.Base.String.

(* flagsAll skipped *)

Axiom allNonDeprecatedFlags : list GHC.Base.String.

Axiom allFlagsDeps : bool -> list GHC.Base.String.

(* flagsAllDeps skipped *)

(* dynamic_flags_deps skipped *)

(* setTarget skipped *)

(* setTargetWithPlatform skipped *)

(* addWay skipped *)

Axiom dynamicTooMkDynamicDynFlags : DynFlags -> DynFlags.

Axiom addWay' : Way -> DynFlags -> DynFlags.

(* initDynFlags skipped *)

Axiom tablesNextToCode : DynFlags -> bool.

Axiom opt_l : DynFlags -> list GHC.Base.String.

Axiom opt_c : DynFlags -> list GHC.Base.String.

Axiom opt_P : DynFlags -> list GHC.Base.String.

(* targetPlatform skipped *)

(* interpretPackageEnv skipped *)

(* versionedAppDir skipped *)

Axiom programName : DynFlags -> GHC.Base.String.

Axiom versionedFilePath : DynFlags -> GHC.Base.String.

Axiom projectVersion : DynFlags -> GHC.Base.String.

Axiom ghcUsagePath : DynFlags -> GHC.Base.String.

Axiom ghciUsagePath : DynFlags -> GHC.Base.String.

Axiom topDir : DynFlags -> GHC.Base.String.

Axiom tmpDir : DynFlags -> GHC.Base.String.

Axiom rawSettings : DynFlags -> list (GHC.Base.String * GHC.Base.String)%type.

Axiom extraGccViaCFlags : DynFlags -> list GHC.Base.String.

Axiom systemPackageConfig : DynFlags -> GHC.Base.String.

Axiom pgm_L : DynFlags -> GHC.Base.String.

Axiom pgm_P : DynFlags -> (GHC.Base.String * list Option)%type.

Axiom pgm_F : DynFlags -> GHC.Base.String.

Axiom pgm_c : DynFlags -> (GHC.Base.String * list Option)%type.

Axiom pgm_s : DynFlags -> (GHC.Base.String * list Option)%type.

Axiom pgm_a : DynFlags -> (GHC.Base.String * list Option)%type.

Axiom pgm_l : DynFlags -> (GHC.Base.String * list Option)%type.

Axiom pgm_dll : DynFlags -> (GHC.Base.String * list Option)%type.

Axiom pgm_T : DynFlags -> GHC.Base.String.

Axiom pgm_windres : DynFlags -> GHC.Base.String.

Axiom pgm_libtool : DynFlags -> GHC.Base.String.

Axiom pgm_lo : DynFlags -> (GHC.Base.String * list Option)%type.

Axiom pgm_lc : DynFlags -> (GHC.Base.String * list Option)%type.

Axiom pgm_i : DynFlags -> GHC.Base.String.

Axiom opt_L : DynFlags -> list GHC.Base.String.

Axiom opt_F : DynFlags -> list GHC.Base.String.

Axiom opt_a : DynFlags -> list GHC.Base.String.

Axiom opt_windres : DynFlags -> list GHC.Base.String.

Axiom opt_lo : DynFlags -> list GHC.Base.String.

Axiom opt_lc : DynFlags -> list GHC.Base.String.

Axiom opt_i : DynFlags -> list GHC.Base.String.

(* setObjTarget skipped *)

Axiom isObjectTarget : HscTarget -> bool.

Axiom targetRetainsAllBindings : HscTarget -> bool.

(* setVerboseCore2Core skipped *)

(* setDumpFlag skipped *)

(* setDumpFlag' skipped *)

(* forceRecompile skipped *)

Axiom isOneShot : GhcMode -> bool.

Axiom isNoLink : GhcLink -> bool.

(* setUnsafeGlobalDynFlags skipped *)

Axiom unsafeGlobalDynFlags : DynFlags.

(* v_unsafeGlobalDynFlags skipped *)

Axiom defaultGlobalDynFlags : DynFlags.

Axiom defaultDynFlags : Settings -> DynFlags.

(* defaultHscTarget skipped *)

(* defaultObjectTarget skipped *)

Axiom mkTablesNextToCode : bool -> bool.

Axiom allowed_combination : list Way -> bool.

Axiom updateWays : DynFlags -> DynFlags.

Axiom mkBuildTag : list Way -> GHC.Base.String.

Axiom wayTag : Way -> GHC.Base.String.

Axiom wayRTSOnly : Way -> bool.

Axiom wayDesc : Way -> GHC.Base.String.

Axiom defaultFlags : Settings -> list GeneralFlag.

(* wayGeneralFlags skipped *)

(* wayUnsetGeneralFlags skipped *)

(* wayOptc skipped *)

(* wayOptl skipped *)

(* wayOptP skipped *)

(* whenGeneratingDynamicToo skipped *)

(* ifGeneratingDynamicToo skipped *)

(* whenCannotGenerateDynamicToo skipped *)

(* ifCannotGenerateDynamicToo skipped *)

(* generateDynamicTooConditional skipped *)

Axiom defaultWays : Settings -> list Way.

Axiom interpWays : list Way.

Axiom interpreterProfiled : DynFlags -> bool.

(* interpreterDynamic skipped *)

(* defaultFatalMessager skipped *)

(* defaultLogAction skipped *)

(* defaultLogActionHPrintDoc skipped *)

(* defaultLogActionHPutStrDoc skipped *)

Axiom defaultFlushOut : FlushOut.

(* defaultFlushErr skipped *)

(* setLanguage skipped *)

(* lang_set skipped *)

(* enableGlasgowExts skipped *)

(* setExtensionFlag skipped *)

(* setExtensionFlag' skipped *)

(* disableGlasgowExts skipped *)

(* unSetExtensionFlag skipped *)

(* unSetExtensionFlag' skipped *)

Axiom safeFlagCheck : bool -> DynFlags -> (DynFlags * list (SrcLoc.Located
                                                           GHC.Base.String))%type.

Axiom unsafeFlagsForInfer : list (GHC.Base.String * (DynFlags -> SrcLoc.SrcSpan)
                                 * (DynFlags -> bool) * (DynFlags -> DynFlags))%type.

Axiom unsafeFlags : list (GHC.Base.String * (DynFlags -> SrcLoc.SrcSpan) *
                         (DynFlags -> bool) * (DynFlags -> DynFlags))%type.

(* xopt_unset skipped *)

(* xopt_set skipped *)

(* flattenExtensionFlags skipped *)

(* languageExtensions skipped *)

(* dopt skipped *)

Axiom dopt_set : DynFlags -> DumpFlag -> DynFlags.

Axiom dopt_unset : DynFlags -> DumpFlag -> DynFlags.

Axiom picPOpts : DynFlags -> list GHC.Base.String.

Axiom packageTrustOn : DynFlags -> bool.

Axiom useUnicodeSyntax : DynFlags -> bool.

Axiom gopt : GeneralFlag -> DynFlags -> bool.

(* unSetGeneralFlag skipped *)

(* setPackageTrust skipped *)

(* flagsPackage skipped *)

(* package_flags_deps skipped *)

(* setGeneralFlag skipped *)

(* unSetGeneralFlag' skipped *)

(* setGeneralFlag' skipped *)

(* setDPHOpt skipped *)

(* setOptLevel skipped *)

(* updOptLevel skipped *)

Axiom gopt_set : DynFlags -> GeneralFlag -> DynFlags.

(* gopt_unset skipped *)

(* unrecognisedWarning skipped *)

(* wopt skipped *)

(* enableUnusedBinds skipped *)

(* setWarningFlag skipped *)

(* wopt_set skipped *)

(* disableUnusedBinds skipped *)

(* unSetWarningFlag skipped *)

(* wopt_unset skipped *)

(* xopt skipped *)

(* dynFlagDependencies skipped *)

Axiom safeHaskellOn : DynFlags -> bool.

Axiom safeImplicitImpsReq : DynFlags -> bool.

Axiom safeDirectImpsReq : DynFlags -> bool.

Axiom safeLanguageOn : DynFlags -> bool.

Axiom safeInferOn : DynFlags -> bool.

(* safeImportsOn skipped *)

(* setSafeHaskell skipped *)

(* combineSafeFlags skipped *)

Axiom getOpts : forall {a}, DynFlags -> (DynFlags -> list a) -> list a.

Axiom getVerbFlags : DynFlags -> list GHC.Base.String.

Axiom setOutputDir : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setObjectDir : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setHiDir : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setStubDir : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setDumpDir : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setDylibInstallName : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setObjectSuf : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setDynObjectSuf : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setHiSuf : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setDynHiSuf : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setHcSuf : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setOutputFile : option GHC.Base.String -> DynFlags -> DynFlags.

Axiom setDynOutputFile : option GHC.Base.String -> DynFlags -> DynFlags.

Axiom setOutputHi : option GHC.Base.String -> DynFlags -> DynFlags.

Axiom setSigOf : GHC.Base.String -> DynFlags -> DynFlags.

Axiom parseSigOf : GHC.Base.String -> SigOf.

Axiom addPluginModuleName : GHC.Base.String -> DynFlags -> DynFlags.

Axiom addPluginModuleNameOption : GHC.Base.String -> DynFlags -> DynFlags.

Axiom addFrontendPluginOption : GHC.Base.String -> DynFlags -> DynFlags.

Axiom parseDynLibLoaderMode : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setDumpPrefixForce : option GHC.Base.String -> DynFlags -> DynFlags.

Axiom setPgmP : GHC.Base.String -> DynFlags -> DynFlags.

Axiom addOptl : GHC.Base.String -> DynFlags -> DynFlags.

Axiom addOptc : GHC.Base.String -> DynFlags -> DynFlags.

Axiom addOptP : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setDepMakefile : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setDepIncludePkgDeps : bool -> DynFlags -> DynFlags.

Axiom addDepExcludeMod : GHC.Base.String -> DynFlags -> DynFlags.

Axiom addDepSuffix : GHC.Base.String -> DynFlags -> DynFlags.

Axiom addCmdlineFramework : GHC.Base.String -> DynFlags -> DynFlags.

Axiom addHaddockOpts : GHC.Base.String -> DynFlags -> DynFlags.

Axiom addGhciScript : GHC.Base.String -> DynFlags -> DynFlags.

Axiom setInteractivePrint : GHC.Base.String -> DynFlags -> DynFlags.

Axiom showOpt : Option -> GHC.Base.String.

(* make_ord_flag skipped *)

(* make_dep_flag skipped *)

(* add_dep_message skipped *)

(* impliedXFlags skipped *)

(* impliedGFlags skipped *)

Axiom turnOn : TurnOnFlag.

Axiom impliedOffGFlags : list (GeneralFlag * TurnOnFlag * GeneralFlag)%type.

Axiom turnOff : TurnOnFlag.

Axiom supportedLanguagesAndExtensions : list GHC.Base.String.

(* supportedExtensions skipped *)

(* xFlags skipped *)

(* xFlagsDeps skipped *)

(* supportedLanguageOverlays skipped *)

Axiom safeHaskellFlagsDeps : list (Deprecation * FlagSpec SafeHaskellMode)%type.

Axiom supportedLanguages : list GHC.Base.String.

Axiom languageFlagsDeps : list (Deprecation * FlagSpec Language)%type.

Axiom fFlags : list (FlagSpec GeneralFlag).

Axiom fFlagsDeps : list (Deprecation * FlagSpec GeneralFlag)%type.

Axiom dFlagsDeps : list (Deprecation * FlagSpec GeneralFlag)%type.

Axiom flagSpecOf : WarningFlag -> option (FlagSpec WarningFlag).

Axiom wWarningFlags : list (FlagSpec WarningFlag).

Axiom wWarningFlagsDeps : list (Deprecation * FlagSpec WarningFlag)%type.

Axiom flagSpec : forall {flag},
                   GHC.Base.String -> flag -> (Deprecation * FlagSpec flag)%type.

Axiom depFlagSpec : forall {flag},
                      GHC.Base.String -> flag -> GHC.Base.String -> (Deprecation * FlagSpec
                      flag)%type.

(* depFlagSpecOp skipped *)

(* flagSpec' skipped *)

(* fLangFlags skipped *)

(* fLangFlagsDeps skipped *)

(* depFlagSpec' skipped *)

(* depFlagSpecOp' skipped *)

Axiom depFlagSpecCond : forall {flag},
                          GHC.Base.String -> flag -> (TurnOnFlag -> bool) -> GHC.Base.String -> (Deprecation
                          * FlagSpec flag)%type.

Axiom negatableFlagsDeps : list (Deprecation * FlagSpec GeneralFlag)%type.

Axiom flagGhciSpec : forall {flag},
                       GHC.Base.String -> flag -> (Deprecation * FlagSpec flag)%type.

(* flagGhciSpec' skipped *)

Axiom flagHiddenSpec : forall {flag},
                         GHC.Base.String -> flag -> (Deprecation * FlagSpec flag)%type.

(* flagHiddenSpec' skipped *)

Axiom hideFlag : forall {a},
                   (Deprecation * FlagSpec a)%type -> (Deprecation * FlagSpec a)%type.

(* mkFlag skipped *)

Axiom deprecatedForExtension : GHC.Base.String -> TurnOnFlag -> GHC.Base.String.

(* useInstead skipped *)

(* nop skipped *)

(* default_PIC skipped *)

Axiom optLevelFlags : list (list GHC.Num.Int * GeneralFlag)%type.

Axiom smallestGroups : WarningFlag -> list GHC.Base.String.

Axiom warningHierarchies : list (list GHC.Base.String).

Axiom warningGroups : list (GHC.Base.String * list WarningFlag)%type.

Axiom minusWallOpts : list WarningFlag.

Axiom minusWOpts : list WarningFlag.

Axiom standardWarnings : list WarningFlag.

Axiom minusWeverythingOpts : list WarningFlag.

Axiom minusWcompatOpts : list WarningFlag.

(* unusedBindsFlags skipped *)

(* glasgowExtsFlags skipped *)

(* rtsIsProfiled skipped *)

(* dynamicGhc skipped *)

(* setWarnSafe skipped *)

(* setWarnUnsafe skipped *)

(* setGenDeriving skipped *)

(* setOverlappingInsts skipped *)

(* setIncoherentInsts skipped *)

(* checkTemplateHaskellOk skipped *)

(* setOptHpcDir skipped *)

(* setRtsOptsEnabled skipped *)

(* setRtsOpts skipped *)

(* addFrameworkPath skipped *)

(* addIncludePath skipped *)

(* addLibraryPath skipped *)

(* addImportPath skipped *)

(* setMainIs skipped *)

(* distrustPackage skipped *)

(* trustPackage skipped *)

(* ignorePackage skipped *)

(* hidePackage skipped *)

(* exposePluginPackageId skipped *)

(* exposePluginPackage skipped *)

(* exposePackageId skipped *)

(* exposePackage skipped *)

(* clearPkgConf skipped *)

(* removeGlobalPkgConf skipped *)

(* removeUserPkgConf skipped *)

(* addPkgConfRef skipped *)

(* setDebugLevel skipped *)

(* setVerbosity skipped *)

(* removeWayDyn skipped *)

(* floatSuffix skipped *)

(* intSuffix skipped *)

(* sepArg skipped *)

(* hasArg skipped *)

(* noArg skipped *)

(* upd skipped *)

(* optIntSuffixM skipped *)

(* intSuffixM skipped *)

(* noArgM skipped *)

(* updM skipped *)

(* setTmpDir skipped *)

Axiom alterSettings : (Settings -> Settings) -> DynFlags -> DynFlags.

Axiom exposePackage' : GHC.Base.String -> DynFlags -> DynFlags.

Axiom parsePackageFlag
        : GHC.Base.String -> (GHC.Base.String -> PackageArg) -> GHC.Base.String -> PackageFlag.

(* parseModuleName skipped *)

(* setUnitId skipped *)

Axiom checkOptLevel : GHC.Num.Int -> DynFlags -> Data.Either.Either
                      GHC.Base.String DynFlags.

Axiom addLdInputs : Option -> DynFlags -> DynFlags.

Axiom splitPathList : GHC.Base.String -> list GHC.Base.String.

Axiom split_marker : GHC.Char.Char.

Axiom can_split : bool.

Axiom cONTROL_GROUP_CONST_291 : DynFlags -> GHC.Num.Int.

Axiom sTD_HDR_SIZE : DynFlags -> GHC.Num.Int.

Axiom pROF_HDR_SIZE : DynFlags -> GHC.Num.Int.

Axiom bLOCK_SIZE_W : DynFlags -> GHC.Num.Int.

Axiom bLOCK_SIZE : DynFlags -> GHC.Num.Int.

Axiom bLOCKS_PER_MBLOCK : DynFlags -> GHC.Num.Int.

Axiom tICKY_BIN_COUNT : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rR1 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rR2 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rR3 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rR4 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rR5 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rR6 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rR7 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rR8 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rR9 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rR10 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rF1 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rF2 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rF3 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rF4 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rF5 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rF6 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rD1 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rD2 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rD3 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rD4 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rD5 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rD6 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rXMM1 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rXMM2 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rXMM3 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rXMM4 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rXMM5 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rXMM6 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rYMM1 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rYMM2 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rYMM3 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rYMM4 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rYMM5 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rYMM6 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rZMM1 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rZMM2 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rZMM3 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rZMM4 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rZMM5 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rZMM6 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rL1 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rSp : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rSpLim : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rHp : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rHpLim : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rCCCS : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rCurrentTSO : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rCurrentNursery : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgRegTable_rHpAlloc : DynFlags -> GHC.Num.Int.

Axiom oFFSET_stgEagerBlackholeInfo : DynFlags -> GHC.Num.Int.

Axiom oFFSET_stgGCEnter1 : DynFlags -> GHC.Num.Int.

Axiom oFFSET_stgGCFun : DynFlags -> GHC.Num.Int.

Axiom oFFSET_Capability_r : DynFlags -> GHC.Num.Int.

Axiom oFFSET_bdescr_start : DynFlags -> GHC.Num.Int.

Axiom oFFSET_bdescr_free : DynFlags -> GHC.Num.Int.

Axiom oFFSET_bdescr_blocks : DynFlags -> GHC.Num.Int.

Axiom sIZEOF_CostCentreStack : DynFlags -> GHC.Num.Int.

Axiom oFFSET_CostCentreStack_mem_alloc : DynFlags -> GHC.Num.Int.

Axiom oFFSET_CostCentreStack_scc_count : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgHeader_ccs : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgHeader_ldvw : DynFlags -> GHC.Num.Int.

Axiom sIZEOF_StgSMPThunkHeader : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgEntCounter_allocs : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgEntCounter_allocd : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgEntCounter_registeredp : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgEntCounter_link : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgEntCounter_entry_count : DynFlags -> GHC.Num.Int.

Axiom sIZEOF_StgUpdateFrame_NoHdr : DynFlags -> GHC.Num.Int.

Axiom sIZEOF_StgMutArrPtrs_NoHdr : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgMutArrPtrs_ptrs : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgMutArrPtrs_size : DynFlags -> GHC.Num.Int.

Axiom sIZEOF_StgSmallMutArrPtrs_NoHdr : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgSmallMutArrPtrs_ptrs : DynFlags -> GHC.Num.Int.

Axiom sIZEOF_StgArrBytes_NoHdr : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgArrBytes_bytes : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgTSO_alloc_limit : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgTSO_cccs : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgTSO_stackobj : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgStack_sp : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgStack_stack : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgUpdateFrame_updatee : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgFunInfoExtraFwd_arity : DynFlags -> GHC.Num.Int.

Axiom sIZEOF_StgFunInfoExtraRev : DynFlags -> GHC.Num.Int.

Axiom oFFSET_StgFunInfoExtraRev_arity : DynFlags -> GHC.Num.Int.

Axiom mAX_SPEC_SELECTEE_SIZE : DynFlags -> GHC.Num.Int.

Axiom mAX_SPEC_AP_SIZE : DynFlags -> GHC.Num.Int.

Axiom mIN_PAYLOAD_SIZE : DynFlags -> GHC.Num.Int.

Axiom mIN_INTLIKE : DynFlags -> GHC.Num.Int.

Axiom mAX_INTLIKE : DynFlags -> GHC.Num.Int.

Axiom mIN_CHARLIKE : DynFlags -> GHC.Num.Int.

Axiom mAX_CHARLIKE : DynFlags -> GHC.Num.Int.

Axiom mUT_ARR_PTRS_CARD_BITS : DynFlags -> GHC.Num.Int.

Axiom mAX_Vanilla_REG : DynFlags -> GHC.Num.Int.

Axiom mAX_Float_REG : DynFlags -> GHC.Num.Int.

Axiom mAX_Double_REG : DynFlags -> GHC.Num.Int.

Axiom mAX_Long_REG : DynFlags -> GHC.Num.Int.

Axiom mAX_XMM_REG : DynFlags -> GHC.Num.Int.

Axiom mAX_Real_Vanilla_REG : DynFlags -> GHC.Num.Int.

Axiom mAX_Real_Float_REG : DynFlags -> GHC.Num.Int.

Axiom mAX_Real_Double_REG : DynFlags -> GHC.Num.Int.

Axiom mAX_Real_XMM_REG : DynFlags -> GHC.Num.Int.

Axiom mAX_Real_Long_REG : DynFlags -> GHC.Num.Int.

Axiom rESERVED_C_STACK_BYTES : DynFlags -> GHC.Num.Int.

Axiom rESERVED_STACK_WORDS : DynFlags -> GHC.Num.Int.

Axiom aP_STACK_SPLIM : DynFlags -> GHC.Num.Int.

Axiom wORD_SIZE_IN_BITS : DynFlags -> GHC.Num.Int.

Axiom wORD_SIZE : DynFlags -> GHC.Num.Int.

Axiom dOUBLE_SIZE : DynFlags -> GHC.Num.Int.

Axiom cINT_SIZE : DynFlags -> GHC.Num.Int.

Axiom cLONG_SIZE : DynFlags -> GHC.Num.Int.

Axiom cLONG_LONG_SIZE : DynFlags -> GHC.Num.Int.

Axiom bITMAP_BITS_SHIFT : DynFlags -> GHC.Num.Int.

Axiom mAX_PTR_TAG : DynFlags -> GHC.Num.Int.

Axiom tAG_MASK : DynFlags -> GHC.Num.Int.

Axiom tAG_BITS : DynFlags -> GHC.Num.Int.

Axiom wORDS_BIGENDIAN : DynFlags -> bool.

Axiom dYNAMIC_BY_DEFAULT : DynFlags -> bool.

Axiom lDV_SHIFT : DynFlags -> GHC.Num.Int.

Axiom iLDV_CREATE_MASK : DynFlags -> GHC.Num.Integer.

Axiom iLDV_STATE_CREATE : DynFlags -> GHC.Num.Integer.

Axiom iLDV_STATE_USE : DynFlags -> GHC.Num.Integer.

Axiom isSse4_2Enabled : DynFlags -> bool.

Axiom isAvxEnabled : DynFlags -> bool.

Axiom isAvx2Enabled : DynFlags -> bool.

Axiom isAvx512cdEnabled : DynFlags -> bool.

Axiom isAvx512erEnabled : DynFlags -> bool.

Axiom isAvx512fEnabled : DynFlags -> bool.

Axiom isAvx512pfEnabled : DynFlags -> bool.

Axiom decodeSize : GHC.Base.String -> GHC.Num.Integer.

(* Unbound variables:
     Type bool list op_zt__ option Data.Either.Either GHC.Base.Eq_ GHC.Base.String
     GHC.Char.Char GHC.Num.Int GHC.Num.Integer Module.Module Module.ModuleName
     Module.ModuleNameEnv SrcLoc.Located SrcLoc.SrcSpan
*)
