Device "MOS" {
    File {
        Grid    = "nmos_final_fps.tdr"
        Plot    = "AC_Cgg"
        Current = "AC_Cgg"
    }

    Electrode {
        { Name="gate"   Voltage=0.0 }
        { Name="body"   Voltage=0.0 }
        { Name="source" Voltage=0.0 }
        { Name="drain"  Voltage=0.0 }
    }

    Physics {
        Temperature = 300
        Fermi
        EffectiveIntrinsicDensity(OldSlotboom)
        Mobility(
            DopingDep
            eHighFieldSaturation(GradQuasiFermi)
            hHighFieldSaturation(GradQuasiFermi)
            Enormal
        )
        Recombination(SRH(DopingDep TempDependence))
    }
}

Plot {
    eDensity hDensity
    TotalCurrent/Vector
    eCurrent/Vector hCurrent/Vector
    eMobility hMobility
    eVelocity hVelocity
    eQuasiFermi hQuasiFermi
    Temperature
    ElectricField/Vector
    Potential SpaceCharge
    Doping DonorConcentration AcceptorConcentration
    SRH Band2BandGeneration Auger
    ImpactIonization
    eGradQuasiFermi/Vector hGradQuasiFermi/Vector
    BandGap BandGapNarrowing
    Affinity
    ConductionBand ValenceBand
    eQuantumPotential
}

Math {
    RelErrControl
    Digits=5
    ErrRef(electron)=1e10
    ErrRef(hole)=1e10
    Iterations=20
    Notdamped=100
    Method=Blocked
    SubMethod=Super
    ACMethod=Blocked
    ACSubMethod=Super
}

File {
    Output    = "AC_Cgg_300K.log"
    ACExtract = "AC_Cgg_300K"
}

System {
    MOS nmos1 (
        "body"=b
        "gate"=g
        "source"=s
        "drain"=d
    )

    Vsource_pset vb (b 0) { dc=0.0 }
    Vsource_pset vs (s 0) { dc=0.0 }
    Vsource_pset vd (d 0) { dc=0.0 }
    Vsource_pset vg (g 0) { dc=0.0 }
}

Solve {
    NewCurrentPrefix="init_"

    Coupled(Iterations=100) {
        Poisson
    }

    Coupled {
        Poisson Electron Hole
    }

    # Set drain voltage to 0.1 V
    Quasistationary(
        InitialStep=0.01
        Increment=1.3
        MaxStep=0.05
        MinStep=1e-5
        Goal { Parameter=vd.dc Voltage=0.1 }
    ) {
        Coupled {
            Poisson Electron Hole
        }
    }

    # First bias gate to -2 V
    Quasistationary(
        InitialStep=0.01
        Increment=1.3
        MaxStep=0.025
        MinStep=1e-5
        Goal { Parameter=vg.dc Voltage=-2.0 }
    ) {
        Coupled {
            Poisson Electron Hole
        }
    }

    NewCurrentPrefix=""

    # AC extraction while sweeping gate from -2 V to +2 V
    Quasistationary(
        InitialStep=0.01
        Increment=1.3
        MaxStep=0.025
        MinStep=1e-5
        Goal { Parameter=vg.dc Voltage=2.0 }
    ) {
        ACCoupled(
            StartFrequency=1e6
            EndFrequency=1e6
            NumberOfPoints=1
            Decade
            Node(g b d s)
            Exclude(vg vb vd vs)
            ACCompute(
                Time=(Range=(0 1) Intervals=40)
            )
        ) {
            Poisson Electron Hole
        }
    }
}

